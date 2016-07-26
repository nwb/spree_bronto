Spree::UserRegistrationsController.class_eval do
  include Spree::Lists

  before_action :load_bronto_lists
  before_action :subscribe_newreg_newsletter

  private
  def load_bronto_lists
    @bronto_lists=current_store.bronto_lists
  end

    def subscribe_newreg_newsletter
    if params.key? :newsletter_signup
     if params['spree_user']['email'] && params['newsletter_signup']
      @bronto_lists.each do |k|
        list=Spree::BrontoList.find(k)

        if k && params['spree_user']['email']
          subscribe_to_list(params['spree_user']['email'], list)
        end
      end
     end
     end
  end
end