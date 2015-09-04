Spree::UserMailer.class_eval do
    def reset_password_instructions(user, token, *args)
        # we do not user this any more
    end


    def confirmation_instructions(user, token, opts={})
      @confirmation_url = spree.spree_user_confirmation_url(:confirmation_token => token, :host => Spree::Store.current.url)

      mail to: user.email, from: from_address, subject: Spree::Store.current.name + ' ' + I18n.t(:subject, :scope => [:devise, :mailer, :confirmation_instructions])
    end

end
