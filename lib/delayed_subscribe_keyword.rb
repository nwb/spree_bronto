DelayedSubscribeKeyword = Struct.new(:store_code, :user, :mobile_number, :keyword, :ops) do
  def perform

    if keyword.nil? || !user
      subscriber_id = -1
    else
      begin
        bronto_config=Spree::BrontoConfiguration.new
        token= bronto_config.account[store_code]['token']
        if user.is_a? String
          email=user
        else
          email=user.email
        end

        contact = BrontoIntegration::Contact.new(token)
        contacts=contact.set_up(email,ops||{})

        subscriber_id= contacts[:id]

        communication = BrontoIntegration::Communication.new(token)
        communication.add_to_keyword(keyword,email,mobile_number)
      rescue => exception
          subscriber_id = -1
          #raise exception
      end
    end

    #unless user.is_a? String
    #  begin
    #  user.bronto_lists << list
    #  user.save!
    #  rescue
    #  end
    #end


  end
  alias_method :perform_without_delay, :perform
end
