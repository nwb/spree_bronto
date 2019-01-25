Spree::ShipmentHandler.class_eval do

    private
    def send_shipped_email
      #ShipmentMailer.shipped_email(id).deliver_later
      order=@shipment.order
      external_key = Spree::BrontoConfiguration.account[order.store.code]["order_shipped"]

      DelayedSend.new( order.store.code,
                       order.email,
                       external_key,
                       order.id.to_s,
                       "order_mailer/order_shipped_plain",
                       "order_mailer/order_shipped_details_html").perform

      message_fields=[]
      field_array={}
      field_array={name:"firstname",content:order.shipping_address.firstname}
      message_fields << field_array
      field_array={name:"tracking",content:order.shipments.first.tracking_url+order.shipments.first.tracking}
      message_fields << field_array

      # field_array={firstname:order.shipping_address.firstname, tracking:order.shipments.first.tr.acking_url+order.shipments.first.tracking}

      Delayed::Job.enqueue(DelayedSMSTrigger.new(order.store.code,
                                                 order.email,
                                                 external_key,
                                                 order.id.to_s,
                                                 message_fields), {priority: 50})

    end

end