DelayedSubscriberDelete = Struct.new(:store_code, :user, :list) do
  def perform
    if list.nil? || !user
      subscriber_id = -1
    else
      begin
        bronto_config=Spree::BrontoConfiguration.new
        token= bronto_config.account[store_code]['token']
        if user.is_a? String
          email=user
        else
          email=user.email
        end
        unless email.empty?
        communication = BrontoIntegration::Communication.new(token)
        communication.remove_from_list(list.title,email)
        end
      rescue => exception
        #raise exception
      end
    end

    #unless user.is_a? String    # update  exact_target_lists
    #  begin
    #    list_del=user.bronto_lists.select{|l| l.id== list.id}
    #    if list_del.length>0
    #      user.bronto_lists.delete(list_del)
    #    end
    #    user.save!
    #  rescue
    #    #raise exception
    #  end
    #end

  end
end