DelayedTrigger = Struct.new(:store_code, :email, :message_name, :attributes, :mail_type) do
  def perform
    return if email.blank?
    begin
      token= Spree::BrontoConfiguration.account[store_code]['token']
      from_email= Spree::BrontoConfiguration.account[store_code]['from_address']
      from_name= Spree::BrontoConfiguration.account[store_code]['from_name']
      reply_email= Spree::BrontoConfiguration.account[store_code]['from_address']
      email_options={:fromEmail =>from_email,:fromName => from_name, :replyEmail => reply_email}

      communication = BrontoIntegration::Communication.new(token)
      communication.trigger_delivery_by_id(message_name,email,'triggered',mail_type||'html',attributes||{},email_options)
    rescue => exception
      #raise exception   # as now only campaign use this and their templates may not be approved. let it go.
    end
  end
end