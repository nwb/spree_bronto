Spree::UsersController.class_eval do
  include Spree::Lists

  before_action :load_bronto_lists
  before_action :check_newsletter

private
  def load_bronto_lists
      @bronto_lists=current_store.bronto_lists
  end

  def check_newsletter
    if params['user'] && params['user']['bronto_list_attributes']
      params['user']['bronto_list_attributes'].each do|k,v|
        list=Spree::BrontoList.find(k)
        if k && @user && v=="true"
          subscribe_to_list(@user, list)
        end

        if k && @user && v=="false"
          unsubscribe_from_list(@user, list)
        end

      end
    end
  end
end