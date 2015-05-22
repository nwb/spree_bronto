Spree::UsersController.class_eval do

before_action :load_bronto_lists

private
  def load_bronto_lists
      @bronto_lists=current_store.bronto_lists
  end

end