Spree::Core::Engine.routes.append do
  namespace :admin do
    resources :bronto_lists do
      collection do
         get 'get_lists'
      end
    end
  end

  resources :orders, :except => [:index, :new, :create, :destroy] do
    patch :subscribe, :on => :member
  end

  get "/account/email_preferences", :to => 'users#email_preferences'

  post "/subscribenewsletter", :to => 'home#subscribenewsletter'
  post "/subscribenewsletters", :to => 'home#subscribenewsletters'
  post "/subscribecampaign", :to => 'home#subscribecampaign'
  post "/subscribecampaign_with_ops", :to => 'home#subscribecampaign_with_ops'

  post "/subscribekeyword", :to => 'home#subscribekeyword'

end

