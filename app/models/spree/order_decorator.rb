Spree::Order.class_eval do

    def deliver_order_confirmation_email
      #OrderMailer.confirm_email(id).deliver_later  # we replace OrderMailer with DelayedSend

      external_key = Spree::BrontoConfiguration.account[store.code]["order_received"]
      Delayed::Job.enqueue(DelayedSend.new( store.code,
                       email,
                       external_key,
                       id.to_s,
                       "order_mailer/order_confirm_plain",
                       "order_mailer/order_confirm_html"), {priority: 50})

      update_column(:confirmation_delivered, true)
    end

    private
    def send_cancel_email
      #OrderMailer.cancel_email(id).deliver_later

      external_key = Spree::BrontoConfiguration.account[store.code]['order_canceled']
      Delayed::Job.enqueue(DelayedSend.new( store.code,
                       email,
                       external_key,
                       id.to_s,
                       "order_mailer/order_cancel_plain",
                       "order_mailer/order_cancel_html"), {priority: 50})
    end

end