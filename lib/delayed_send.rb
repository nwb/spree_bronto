DelayedSend = Struct.new(:store_code, :email, :message_name, :order_id, :plain_view, :html_view) do
  def perform
    return if (email.blank? || store_code.blank?)

    #Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'dj.log'))

    #Delayed::Worker.logger.debug("Log the bronto config: #{Spree::BrontoConfiguration.account[store_code].inspect}")

    #byebug
    #store_code ||= 'nwb'
    order = Spree::Order.find(order_id)
    token= Spree::BrontoConfiguration.account[store_code]['token']
    from_email= Spree::BrontoConfiguration.account[store_code]['from_address']
    from_name= Spree::BrontoConfiguration.account[store_code]['from_name']
    reply_email= Spree::BrontoConfiguration.account[store_code]['from_address']
    email_options={:fromEmail =>from_email,:fromName => from_name, :replyEmail => reply_email}


    view = ActionView::Base.new(Rails::Application::Configuration.new(Rails.root).paths["app/mailers/spree"])
    view.view_paths<<File.join(File.dirname(__FILE__), '../app/mailers/spree')

    attributes = {:First_Name => order.bill_address.firstname,
                 :Last_name => order.bill_address.lastname}

    attributes[:SENDTIME__CONTENT1] = view.render(plain_view, :order => order) unless plain_view.nil?
    attributes[:SENDTIME__CONTENT2] = (view.render(html_view, :order => order)).gsub(/\n/,'').html_safe unless html_view.nil?

    begin
      communication = BrontoIntegration::Communication.new(token)
      communication.trigger_delivery_by_id(message_name,email,'transactional','html',attributes,email_options)

    rescue => exception
      #begin    #handle the transactional contact in case the message is not approved for transactional.
      #  contact = BrontoIntegration::Contact.new(token)
      #  contact.update_status(email,'active')
      #  communication.trigger_delivery_by_id(message_name,email,'triggered','html',attributes,email_options)
      #rescue => exception
        raise exception unless exception.to_s.include? 'Error Code: 303'
      #end
    end
  end

  if Spree::BrontoConfiguration.account['handle_asynchronously']
     handle_asynchronously :perform, :priority => 20
  end
end