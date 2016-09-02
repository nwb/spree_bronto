Spree::OrderMailer.class_eval do
  def confirm_email(order, resend = false)
    @order = order.respond_to?(:id) ? order : Spree::Order.find(order)

    store=@order.store
    external_key = Spree::BrontoConfiguration.account[store.code]["order_received"]
    Delayed::Job.enqueue(DelayedSend.new( store.code,
                                          @order.email,
                                          external_key,
                                          @order.id.to_s,
                                          "order_mailer/order_confirm_plain",
                                          "order_mailer/order_confirm_details_html"), {priority: 50})

  end
end