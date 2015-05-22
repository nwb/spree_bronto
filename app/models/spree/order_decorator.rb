module Spree
  Order.class_eval do

    def deliver_order_confirmation_email
      #OrderMailer.confirm_email(id).deliver_later  # we replace OrderMailer with DelayedSend

      external_key = Spree::BrontoConfiguration.account[store.code]["order_received"]
      DelayedSend.new( store.code,
                       email,
                       external_key,
                       id.to_s,
                       "order_mailer/order_confirm_plain",
                       "order_mailer/order_confirm_html").perform

      update_column(:confirmation_delivered, true)
    end

    private
    def send_cancel_email
      #OrderMailer.cancel_email(id).deliver_later

      external_key = Spree::BrontoConfiguration.account[store.code]['order_canceled']
      DelayedSend.new( store.code,
                       email,
                       external_key,
                       id.to_s,
                       "order_mailer/order_cancel_plain",
                       "order_mailer/order_cancel_html").perform
    end
  end
end