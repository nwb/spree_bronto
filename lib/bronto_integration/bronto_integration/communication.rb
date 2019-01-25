module BrontoIntegration
  class Communication
    attr_reader :token, :bronto_client

    def initialize(token, client = nil)
      @token = token
      @bronto_client = client || Bronto.new(token)
    end

    def add_to_list(list_name,email)
      Contact.new(token, bronto_client).find_or_create email

      if list_name.is_a? Array
        list_name.each do |list|
          bronto_client.add_to_list list, email
        end
      else
        bronto_client.add_to_list list_name, email
      end
    end

    def remove_from_list(list_name,email)
      if list_name.is_a? Array
        list_name.each do |list|
          bronto_client.remove_from_list list, email
        end
      else
        bronto_client.remove_from_list list_name, email
      end
    end

    def remove_from_all_lists(lists, email)
      lists = bronto_client.read_lists
      lists.map { |l| bronto_client.remove_from_list l[:name], email }
    end

    def trigger_delivery(message_name,recipient_email,delivery_type,mail_type,variables_payload, mail_options)
      bronto_client.add_deliveries(mail_options.merge build(message_name,recipient_email,delivery_type,mail_type,variables_payload))
    end

    def trigger_delivery_by_id(message_id,recipient_email,delivery_type,mail_type,variables_payload, mail_options)
      bronto_client.add_deliveries(mail_options.merge build_with_id(message_id,recipient_email,delivery_type,mail_type,variables_payload))
    end

    #sms section
    #to_do: this function is just a place holder right now
    def trigger_sms_delivery(message_name,recipient_email,delivery_type,mail_type,variables_payload, mail_options)
      bronto_client.add_sms_deliveries(mail_options.merge build(message_name,recipient_email,delivery_type,mail_type,variables_payload))
    end

    def trigger_sms_delivery_by_id(message_id,recipient_email,delivery_type,content,keyword_id, message_fields)
      bronto_client.add_sms_deliveries(build_sms_with_id(message_id,recipient_email,delivery_type,content,keyword_id,message_fields))
    end

    def add_to_keyword(keyword_name,email,mobileNumber)
      contact=Contact.new(token, bronto_client)
      contact.find_or_create email
      contact.update_mobile(email,mobileNumber) unless mobileNumber.nil?
      keyword={:name=>keyword_name}
      contact={:email=>email}
      bronto_client.add_to_sms_keyword keyword, [contact]
    end

    def sms_keyword_id(keyword)
      message = bronto_client.read_sms_keywords keyword
      message[:id]
    end
    #sms done

    def message_id(message_name)
      message = bronto_client.read_messages message_name
      message[:id]
    end

    def contact_id(recipient_email)
      contact = Contact.new(token, bronto_client)
      contact.get_id_by_email recipient_email
    end

    def build(message_name,recipient_email,delivery_type,mail_type,variables_payload={})   # default to triggered
      {
          start: Time.new().iso8601(),
          messageId: message_id(message_name),
          type: delivery_type || 'triggered',
          recipients: [
          { id: contact_id(recipient_email), type: 'contact' }
      ],
          fields: variables_payload.map do |key, value|
        { name: key.to_s, type: mail_type || 'html', content: value.to_s }
      end
      }
    end

    def build_with_id(message_api_id,recipient_email,delivery_type,mail_type,variables_payload={})   # default to triggered
      {
          start: Time.new().iso8601(),
          messageId: message_api_id,
          type: delivery_type || 'triggered',
          recipients: [
              { id: contact_id(recipient_email), type: 'contact' }
          ],
          fields: variables_payload.map do |key, value|
            { name: key.to_s, type: mail_type || 'html', content: value.to_s }
          end
      }
    end

    def build_sms_with_id(message_api_id,recipient_email,delivery_type,content,keyword_id,message_fields)   # default to triggered
      {
          start: Time.new().iso8601(),
          messageId: message_api_id,
          content:content,
          recipients: [
              { id: contact_id(recipient_email),  type: 'contact', deliveryType: delivery_type},
              { id: keyword_id,  type: 'keyword', deliveryType: 'eligible'}
          ],
          fields: message_fields
      }
    end
  end
end