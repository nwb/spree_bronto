require 'savon'

class Bronto
  attr_reader :client, :token

  class ValidationError < StandardError; end

  # NOTE Try building a response object?

  def initialize(token)
    @token = token
    @client = Savon.client(
        ssl_verify_mode: :none,
        wsdl: 'https://api.bronto.com/v4?wsdl',
        log_level: :debug,
        log: true,
        namespace_identifier: :v4,
        env_namespace: :soapenv
    )
  end

  # Ref: http://dev.bronto.com/api/v4/functions/add/addorupdateorders
  def add_or_update_orders(data)
    response = client.call(
        :add_or_update_orders,
        soap_header: soup_header,
        message: { :orders => data }
    )

    result = get_results response.body[:add_or_update_orders_response]

    if result[:is_error]
      raise ValidationError, "(Error Code: #{result[:error_code]}) #{result[:error_string]}"
    else
      result
    end
  end

  # Ref: http://dev.bronto.com/api/v4/functions/add/addorupdatecontacts
  #
  # Successful example:
  #
  #   {:id=>"ac41a110-bd21-4bf6-b061-625dfa428a27", :is_new=>true, :is_error=>false, :error_code=>"0"}
  #
  # Error example:
  #   
  #   {:is_error=>true, :error_code=>"319", :error_string=>"Invalid mobile number: 86 9999-6666"}
  #
  def add_or_update_contacts(data)
    response = client.call(
        :add_or_update_contacts,
        soap_header: soup_header,
        message: { :contacts => data }
    )

    result = get_results response.body[:add_or_update_contacts_response]

    if result[:is_error]
      raise ValidationError, "(Error Code: #{result[:error_code]}) #{result[:error_string]}"
    else
      result
    end
  end

  def read_contacts(email)
    response = client.call(
        :read_contacts,
        soap_header: soup_header,
        message: {
            :filter => [:email => { :operator => 'EqualTo', :value => email }],
            :includeLists => false,
            :fields => 'id',
            :pageNumber => 1,
            :includeSMSKeywords => false,
            :includeGeoIPData => false,
            :includeTechnologyData => false,
            :includeRFMData => false
        }
    )

    response.body[:read_contacts_response][:return]
  end

  def update_contacts(data)
    response = client.call(
        :update_contacts,
        soap_header: soup_header,
        message: { :contacts => data }
    )

    result = get_results response.body[:update_contacts_response]

    if result[:is_error]
      raise ValidationError, "(Error Code: #{result[:error_code]}) #{result[:error_string]}"
    else
      result
    end
  end

  def read_fields(name)
    response = client.call(
        :read_fields,
        soap_header: soup_header,
        message: {
            filter: {
                name: { operator: 'EqualTo', value: name }
            }
        }
    )

    response.body[:read_fields_response][:return]
  end

  # Ref: http://dev.bronto.com/api/v4/functions/read/readmessages
  def read_messages(message_name)
    if !! message_name
      filter= {
          :name =>  [{ operator: 'EqualTo', :value => message_name }]
      }
    else
      filter= {}
    end

    response = client.call(
        :read_messages,
        soap_header: soup_header,
        message: {
            :filter => filter,
            includeContent: false,
            pageNumber: 1
        })

    result = response.body[:read_messages_response][:return]

    if result.blank? || result[:id].blank?
      raise Bronto::ValidationError, "Couldn't find the message template for \"#{message_name}\""
    end

    result
  end

  # Ref: http://dev.bronto.com/api/v4/functions/add/adddeliveries
  def add_deliveries(data)
    response = client.call(
        :add_deliveries,
        soap_header: soup_header,
        message: { deliveries: data }
    )

    result = get_results response.body[:add_deliveries_response]

    if result[:is_error]
      raise ValidationError, "(Error Code: #{result[:error_code]}) #{result[:error_string]}"
    else
      result
    end
  end

  # Ref: http://dev.bronto.com/api/v4/functions/add/addtolist
  def add_to_list(list_name, contact_email)
    response = client.call(
        :add_to_list,
        soap_header: soup_header,
        message: {
            list: {
                name: list_name
            },
            contacts: {
                email: contact_email
            }
        }
    )

    result = response.body[:add_to_list_response][:return][:results]

    if result[:is_error]
      raise ValidationError, "(Error Code: #{result[:error_code]}) #{result[:error_string]}"
    else
      result
    end
  end

  # Ref: http://dev.bronto.com/api/v4/functions/miscellaneous/removefromlist
  def remove_from_list(list_name, contact_email)
    response = client.call(
        :remove_from_list,
        soap_header: soup_header,
        message: {
            list: { name: list_name },
            contacts: {
                email: contact_email
            }
        }
    )

    result = response.body[:remove_from_list_response][:return][:results]

    if result[:is_error]
      raise ValidationError, "(Error Code: #{result[:error_code]}) #{result[:error_string]}"
    else
      result
    end
  end

  # Ref: http://dev.bronto.com/api/v4/functions/read/readlists
  def read_lists
    response = client.call(
        :read_lists,
        soap_header: soup_header,
        message: { :filter => {} }
    )

    lists = response.body[:read_lists_response][:return]

    if lists.is_a? Hash
      [lists]
    else
      lists
    end
  end

  def read_list_by_name(list_name)

    filter={name: [{ operator: 'EqualTo', :value =>list_name }]  }
    response = client.call(
        :read_lists,
        soap_header: soup_header,
        message: { :filter => filter, :pageNumber=>1 }
    )

    lists = response.body[:read_lists_response][:return]

    if lists.is_a? Hash
      [lists]
    else
      lists
    end
  end

  private
  def session_id
    return @session_id if @session_id

    login_response = @client.call(:login, message: { :api_token => token })
    @session_id = login_response.body[:login_response][:return]
  end

  def soup_header
    { 'v4:sessionHeader' => { :session_id => session_id } }
  end

  def get_results(body)
    body[:return][:results]
  end
end