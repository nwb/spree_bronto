module Spree
   module Lists
     extend ActiveSupport::Concern

    def autosubscribe_list(store)
      lists=Spree::BrontoList.where(:store_id =>store.id,:subscribe_all_new_users =>true)
      lists[0] if lists
    end

    def create_subscriber(user)

        store=current_store
        list = autosubscribe_list(store)

      subscribe_to_list(user, list) unless !list

      # synchronize the subscription list from bronto this customer subscribed before registration
      unless !user || (user.is_a? String)
        begin
          user.reload
          bronto=Bronto.new(Spree::BrontoConfiguration.account[store.code]['bronto_token'])
          contact=bronto.read_contacts(user.email,true)
          list_ids=contact[:list_ids]
          if list_ids
            unless list_ids.class == Array
              list_ids=[list_ids]
            end
            list_ids.each do |l|
              list=Spree::BrontoList.find_by_list_id(l)
              if !!list && (!user.bronto_lists.map(&:list_id).include? l )
                user.exact_target_subscriber_id = contact[:id]  #seems we do not need this
                user.bronto_lists << list
                user.save!
              end
            end
          end

        rescue
          # do nothing here at this moment
        end
      end

    end

    def subscribe_to_list(user, list)

      order=current_order

      pwb_cat=''
      pwbCat = lambda{|order|
        iscat=false
        order.line_items.each do |item|
          if item.variant.product.taxons.map{|t| t.id}.include?(3002)
            iscat=true
          end
        end
        if iscat
          'cat'
        else
          'dog'
        end
      }
      if order
        #logger.debug 'call subscribe_to_list there is a order'
        store=order.store
        store_code=store.code
        pwb_cat= (store_code=="pwb" ? pwbCat.call(order) : '')
      else
        store_code=current_store.code
        pwb_cat=''
      end
      #logger.debug '-- found the pwb_cat: ' + pwb_cat

      Delayed::Job.enqueue( DelayedSubscriberAdd.new(store_code, user, list, {:C_or_D => pwb_cat}), {priority: 5} )

      unless !user || (user.is_a? String)
        user.bronto_lists << list
        user.save!
      end

    end

    def unsubscribe_from_list(user, list)

      store = current_store
      Delayed::Job.enqueue( DelayedSubscriberDelete.new(store.code, user, list), {priority: 5} )

      unless user.is_a? String    # update  exact_target_lists
        begin
          list_del=user.bronto_lists.select{|l| l.id== list.id}
          if list_del.length>0
            user.bronto_lists.delete(list_del)
          end
          user.save!
        rescue
          #raise exception
        end
      end

    end

    #private
    #CONTROLLER Actions
    def get_bronto_lists
      @bronto_lists = Spree::BrontoList.where(:visible => true)
    end

    def update_bronto_lists
      return unless params.key? :bronto_list

      unless @checkout.nil?
        session[ :bronto_list ] = []
      end

      @user = @checkout.order.user if @user.nil? && !@checkout.nil?

      params[:bronto_list].each do |id, do_subscribe|
        do_subscribe = (do_subscribe == "true")
        list = Spree::BrontoList.find(id)
        if !@checkout.nil? &&  do_subscribe
          session[ :bronto_list ] << id
        end

        if @user.nil? && !@checkout.nil? #guest checkout
          if do_subscribe
            #subscribe
            subscribe_to_list(@checkout.email, list)
          else
            #unsubscribe
            unsubscribe_from_list(@checkout.email, list)
          end
        else #normal checkout
          if do_subscribe
            #subscribe
            unless @user.bronto_lists.include? list
              subscribe_to_list(@user, list)
            end
          else
            #unsubscribe
            if @user.bronto_lists.include? list
              unsubscribe_from_list(@user, list)
            end
          end
        end
      end

    end
  end
end
