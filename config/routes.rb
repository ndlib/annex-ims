Rails.application.routes.draw do

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # These could be better organized, maybe. Nested resource routes might be better.

  get 'trays/shelves', to: 'trays#index', as: 'trays'
  post 'trays/shelves', to: 'trays#scan', as: 'scan_tray'
  get 'trays/shelves/:id', to: 'trays#show', as: 'show_tray'
  post 'trays/shelves/:id', to: 'trays#associate', as: 'associate_tray'
  post 'trays/shelves/:id/dissociate', to: 'trays#dissociate', as: 'dissociate_tray'
  post 'trays/shelves/:id/shelve', to: 'trays#shelve', as: 'shelve_tray'
  post 'trays/shelves/:id/unshelve', to: 'trays#unshelve', as: 'unshelve_tray'
  get 'trays/shelves/:id/wrong', to: 'trays#wrong', as: 'wrong_tray'

  get 'trays/items', to: 'trays#items', as: 'trays_items'
  post 'trays/items', to: 'trays#scan_item', as: 'scan_tray_item'
  get 'trays/items/:id', to: 'trays#show_item', as: 'show_tray_item'
  post 'trays/items/:id', to: 'trays#associate_item', as: 'associate_tray_item'
  post 'trays/items/:id/dissociate', to: 'trays#dissociate_item', as: 'dissociate_tray_item'

  post 'trays/:id/withdraw', to: 'trays#withdraw', as: 'withdraw_tray'

  get 'items', to: 'items#index', as: 'items'
  get 'items/scan', to: 'items#scan', as: 'scan_item'
  get 'items/:id', to: 'items#show', as: 'show_item'
  post 'items/:id/multiplex', to: 'items#multiplex', as: 'item_multiplex'

  get 'search', to: 'search#index', as: 'search'

  # You can have the root of your site routed with "root"
  root 'welcome#index'

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
