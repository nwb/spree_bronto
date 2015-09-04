Spree::OrdersController.class_eval do
  include Spree::Lists

  def subscribe
    @order = Spree::Order.find_by_number!(params[:id])
    list = Spree::BrontoList.find( params[ :list ] )
    unless list.nil?
      unless @order.user.nil?
        dest = @order.user
      else
        dest = @order.email
      end
      unless dest.nil?
        subscribe_to_list(dest, list)
        respond_to do |format|
          format.html {
            flash[:notice] = Spree.t( :subscription_sent ) unless session[ :return_to ]
            redirect_to checkout_state_path(@order.state)
          }
          format.js {
            render :json => ({
                       :success => true,
                       :message => Spree.t( :subscription_sent )
                   }).to_json
          }
        end
      else
        respond_to do |format|
          format.html {
            flash[:error] = Spree.t( :subscription_notsent ) unless session[ :return_to ]
            redirect_to checkout_state_path(@order.state)
          }
          format.js {
            render :json => ({
                       :success => false,
                       :message => Spree.t( :subscription_notsent )
                   }).to_json
          }
        end
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = Spree.t( :no_such_list ) unless session[ :return_to ]
          redirect_to checkout_state_path(@order.state)
        }
        format.js {
          render :json => ({
                     :success => false,
                     :message => Spree.t( :no_such_list )
                 }).to_json
        }
      end
    end
  end
end