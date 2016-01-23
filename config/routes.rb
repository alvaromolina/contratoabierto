Contratoabierto::Application.routes.draw do
  

  resources :contract_reports
  resources :motives

  resources :contract_budget_items

  get '/about' => 'contracts#about'
  get '/data' => 'contracts#data'
  get '/home' => 'contracts#home'
  get '/news' => 'contracts#news'
  get '/news1' => 'contracts#news1'
  get '/news2' => 'contracts#news2'
  get '/news3' => 'contracts#news3'
  get '/news4' => 'contracts#news4'

  get '/datos' => 'contracts#datos'
  
  get '/mobile' => 'contracts#mobile'
  get '/subscriptions' => 'contracts#subscriptions'



  resources :contract_documents
  resources :contract_forms
  resources :contracts do
    get :autocomplete_entity_name, :on => :collection
  end

  resources :statuses

  resources :regulations

  resources :regions

  resources :modes

  resources :entities

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".



  # You can have the root of your site routed with "root"
  root 'contracts#home'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
