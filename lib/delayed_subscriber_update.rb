DelayedSubscriberUpdate = Struct.new(:token, :order_id) do

  def perform
    order = Spree::Order.find(order_id)

    if order.user.nil?
      email=order.email
      user_id=''
      else
      user=order.user.reload #reload the user to be sure we have the most uptodate record
      email=user.email
      user_id=order.user.id
    end

      if email.length > 0
        begin
            address=order.bill_address
        fields={          # these fields neeb be created in bronto, otherwise they won't get updated.
            :customer_id => user_id,
            :firstname => address.firstname,
            :lastname => address.lastname,
            :address1 => address.address1,
            :address2 => address.address2,
            :phone_home => address.phone,
            :postal_code => address.zipcode,
            :city => address.city,
            :state_province => (address.state_id.nil? ? address.state_name.to_s : address.state.name),
            :country => address.country.name
            }
        contact = BrontoIntegration::Contact.new(token)
        contacts=contact.set_up(email,fields)
        rescue => exception
          # should just send email to operations and go ahead
          #raise exception
        end
      end
  end
end