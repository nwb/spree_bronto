Spree::HomeController.class_eval do

  def subscribenewsletter
    name=params[:name] || ''
    email=params[:email]
    receipt=params[:receipt] || ''
    subject=params[:subject] || 'Customer Record'
    if receipt.length>0
      external_key = Spree::BrontoConfiguration.account[current_store.code]["simple_send"]
      params.delete('action')
      params.delete('receipt')
      params.delete('authenticity_token')
      params.delete('controller')
      params.delete('subject')
      params.delete('cc_receipt')
      the_content=''
      params.each do |k,v|
        the_content += k + ' : ' + v.to_s + '<br/>'
      end
      et_a={:SENDTIME__CONTENT2 => the_content, :SENDTIME__CONTENT1 => subject}
      #et_a={:SENDTIME__CONTENT2 => 'Name: ' + name +'<br/>Email: ' + email + '<br/>Address: ' + params[:address]  + '<br/>City: ' + params[:city] + '<br/>State: ' + params[:state]  +'<br/>Zip: ' + params[:zip]  +'<br/>Phone: ' + params[:phone]  +'<br/>Credentials: ' + params[:credentials]}
      Delayed::Job.enqueue DelayedSimpleSend.new(current_store.code, receipt, external_key, et_a,'html')
      cc_receipt= params[:cc_receipt] || ''
      if cc_receipt.length>0
        Delayed::Job.enqueue DelayedSimpleSend.new(current_store.code, cc_receipt, external_key, et_a,'html')
      end
    end
    if email.length>0
      if current_store.code == 'pwb'
        title='Pets & Products Newsletter'
      elsif current_store.code == 'he'
        title='HairEssentials Products Newsletter'
      else
        title='Natural Products Newsletter'
      end
      campaign= Spree::BrontoList.find_by_title(title)
      if !!campaign
        Delayed::Job.enqueue DelayedSubscriberAdd.new(current_store.code, email, campaign, {:First_Name => name})
      end
      render :json => ({
                 :success => true,
                 :message => t( :subscription_sent )
             }).to_json
    else
      render :json => ({
                 :success => false,
                 :message => t( :subscription_notsent )
             }).to_json
    end
    #redirect_to "/meetexperts"
    #render :js =>'alert("Our server temperarily busy, please try again later.")'

  end

  # sign up compaign flexible form, like the one for newsletter.
  def subscribecampaign
    name=params[:name] || ''
    email=params[:email]
    campaign_id=params[:campaign_id] || ''
    if email.length>0
      campaign=Spree::BrontoList.find_by_list_id(campaign_id)
      if !!campaign
        options=cookies[:campaign_options] || '{}'
        options=Hash[JSON.parse(options).map{|(k,v)| [k.to_sym,v]}]
        Rails.logger.info "find campaign_options cookie: #{cookies.inspect}"
        Delayed::Job.enqueue DelayedSubscriberAdd.new(current_store.code, email, campaign, {:First_Name => name})
      end

      drop_email_key=params[:drop_email_key] || ''
      unless drop_email_key.blank?
        Delayed::Job.enqueue DelayedSimpleSend.new(current_store.code, email, drop_email_key, {},'html')
      end
      render :json => ({
                 :success => true,
                 :message => t( :subscription_sent )
             }).to_json
    else
      render :json => ({
                 :success => false,
                 :message => t( :subscription_notsent )
             }).to_json
    end

  end


  # sign up compaign flexible form, like the one for newsletter.
  def subscribecampaign_with_ops
    email=params[:email]
    campaign_id=params[:campaign_id] || ''
    ops=params[:ops]
    if email.length>0
      campaign=Spree::BrontoList.find_by_list_id(campaign_id)
      if !!campaign
        Delayed::Job.enqueue DelayedSubscriberAdd.new(current_store.code, email, campaign,ops)
      end

      drop_email_key=params[:drop_email_key] || ''
      unless drop_email_key.blank?
        Delayed::Job.enqueue DelayedSimpleSend.new(current_store.code, email, drop_email_key, {},'html')
      end

      render :json => ({
                 :success => true,
                 :message => t( :subscription_sent )
             }).to_json
    else
      render :json => ({
                 :success => false,
                 :message => t( :subscription_notsent )
             }).to_json
    end

  end

end