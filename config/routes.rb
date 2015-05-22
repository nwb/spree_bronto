Spree::Core::Engine.routes.append do
  namespace :admin do
    resources :bronto_lists do
      collection do
         get 'get_lists'
      end
    end
  end
end