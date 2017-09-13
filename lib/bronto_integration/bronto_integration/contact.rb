module BrontoIntegration
  class Contact

    attr_reader :token, :bronto_client

    def initialize(token,  client = nil)
      @token=token
      @bronto_client = client || Bronto.new(token)
    end

    def get_id_by_email(email)
      unless contact = bronto_client.read_contacts(email)
        contact = bronto_client.add_or_update_contacts({ email: email })
      end

      contact[:id]
    end

    alias :find_or_create :get_id_by_email

    def set_up(email,fields)
      bronto_client.add_or_update_contacts build(email,fields)
    end

    def update_status(email,status)
      bronto_client.update_contacts({:email => email, :status => status})
    end

    def update_mobile(email,mobileNumber)
      bronto_client.update_contacts({:email => email, :mobileNumber => mobileNumber})
    end

    #SMSKeywordIDs=['0bbe04200000000000000000000000000e4f']
    def update_sms_keyword_ids(email,sms_keyworkd_ids)
      bronto_client.update_contacts({:email => email, :SMSKeywordIDs => sms_keyworkd_ids})
    end

    def get_sms_keyword_ids_by_email(email)

      get_contact_by_email(email)[:SMSKeywordIDs]
    end

    def get_contact_by_email(email)
      unless contact = bronto_client.read_contacts(email)
        contact = bronto_client.add_or_update_contacts({ email: email })
      end

      contact
    end

    def build(email,fields)
      {
          :email => email,
          :fields => fields(fields).reject{|f| f[:fieldId]==nil}          #delete the non-exist fields
      }
    end

    def fields(fields)
      fields = (fields || []).map do |key, value|
        {
            :fieldId => get_field_id(key.to_s),
            :content => value.to_s
        }
      end
    end

    def get_field_id(name)
      # use cache to reduce the field id query
      Rails.cache.fetch("bronto_field_#{@token}_#{name}", :expires_in => 15.hours) {
      result = bronto_client.read_fields name
      result[:id] if result.is_a? Hash
      }
    end
  end
end