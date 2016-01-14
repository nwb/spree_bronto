module Spree
  User.class_eval do

    has_and_belongs_to_many :bronto_lists, class_name: "Spree::BrontoList", join_table: :spree_bronto_lists_users

    accepts_nested_attributes_for :bronto_lists

    def deliver_password_reset_instructions!(current_store)

      #@edit_password_reset_url = edit_spree_user_password_url(:reset_password_token => token, :host => current_store.url)

      #mail to: user.email, from: from_address, subject: Spree::Store.current.name + ' ' + I18n.t(:subject, :scope => [:devise, :mailer, :reset_password_instructions])

      #Bronto sending
      #trigger the email directly here.
      store_code= current_store.code
      token= Spree::BrontoConfiguration.account[store_code]['token']
      from_email= Spree::BrontoConfiguration.account[store_code]['from_address']
      from_name= Spree::BrontoConfiguration.account[store_code]['from_name']
      reply_email= Spree::BrontoConfiguration.account[store_code]['from_address']
      email_options={:fromEmail =>from_email,:fromName => from_name, :replyEmail => reply_email}

      user_order=orders.select{|o| o.state='complete'}.last

      message_name= Spree::BrontoConfiguration.account[current_store.code]['password_reset']

      attributes = {:First_Name => user_order.ship_address.firstname} unless !user_order
      attributes = {:First_Name => user_order.ship_address.lastname} unless !user_order

      attributes||={}
      attributes[:SENDTIME__CONTENT1] = reset_password_token
      attributes[:SENDTIME__CONTENT2] = reset_password_token

      begin
        communication = BrontoIntegration::Communication.new(token)
        communication.trigger_delivery_by_id(message_name,email,'transactional','html',attributes,email_options)

      rescue => exception
        begin    #handle the transactional contact in case the message is not approved for transactional.
          contact = BrontoIntegration::Contact.new(token)
          contact.update_status(email,'active')
          communication.trigger_delivery_by_id(message_name,email,'triggered','html',attributes,email_options)
        rescue => exception
          raise exception
        end
      end


    end

    def deliver_confirmation_instructions(current_store)

      store_code= current_store.code
      token= Spree::BrontoConfiguration.account[store_code]['token']
      from_email= Spree::BrontoConfiguration.account[store_code]['from_address']
      from_name= Spree::BrontoConfiguration.account[store_code]['from_name']
      reply_email= Spree::BrontoConfiguration.account[store_code]['from_address']
      email_options={:fromEmail =>from_email,:fromName => from_name, :replyEmail => reply_email}

      message_name= Spree::BrontoConfiguration.account[current_store.code]['new_account']
      email=self.email

      user_order=orders.select{|o| o.state='complete'}.last
      attributes = {:First_Name => "Customer"}
      attributes[:First_Name] = user_order.ship_address.firstname unless !user_order
      attributes[:emailaddr] = self.email


      begin
        communication = BrontoIntegration::Communication.new(token)
        communication.trigger_delivery_by_id(message_name,email,'transactional','html',attributes,email_options)

      rescue => exception
        begin    #handle the transactional contact in case the message is not approved for transactional.
          contact = BrontoIntegration::Contact.new(token)
          contact.update_status(email,'active')
          communication.trigger_delivery_by_id(message_name,email,'triggered','html',attributes,email_options)
        rescue => exception
          raise exception
        end
      end
    end


  end
end