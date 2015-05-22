Spree::CheckoutController.class_eval do

  def load_order_with_lock
    @order = current_order(lock: true)
    @bronto_lists=current_store.bronto_lists.select{|l| l.visible && !l.subscribe_all_new_users}
    redirect_to spree.cart_path and return unless @order
  end

end