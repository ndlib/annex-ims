Rails.application.routes.draw do

  devise_for :users
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
  get 'trays/shelves/:id/wrong_shelf', to: 'trays#wrong_shelf', as: 'wrong_shelf'
  get 'trays/shelves/:id/wrong_tray/:barcode', to: 'trays#wrong_tray', as: 'wrong_tray'

  get 'trays/items', to: 'trays#items', as: 'trays_items'
  post 'trays/items', to: 'trays#scan_item', as: 'scan_tray_item'
  get 'trays/items/:id', to: 'trays#show_item', as: 'show_tray_item'
  post 'trays/items/:id', to: 'trays#associate_item', as: 'associate_tray_item'
  post 'trays/items/:id/dissociate', to: 'trays#dissociate_item', as: 'dissociate_tray_item'
  get 'trays/items/:id/missing', to: 'trays#missing', as: 'missing_tray_item'

  post 'trays/:id/withdraw', to: 'trays#withdraw', as: 'withdraw_tray'

  get 'shelves/items', to: 'shelves#index', as: 'shelves'
  post 'shelves/items', to: 'shelves#scan', as: 'scan_shelf'
  get 'shelves/items/:id', to: 'shelves#show', as: 'show_shelf'
  post 'shelves/items/:id', to: 'shelves#associate', as: 'associate_shelf_item'
  post 'shelves/items/:id/dissociate', to: 'shelves#dissociate', as: 'dissociate_shelf_item'
  get 'shelves/items/:id/wrong/:barcode', to: 'shelves#wrong', as: 'wrong_shelf_item'

  get 'items', to: 'items#index', as: 'items'
  get 'items/scan', to: 'items#scan', as: 'scan_item'
  get 'items/issues', to: 'items#issues', as: 'issues'
  post 'items/resolve', to: 'items#resolve', as: 'resolve_issue'
  get 'items/:id', to: 'items#show', as: 'show_item'
  post 'items/:id/restock', to: 'items#restock', as: 'item_restock'
  get 'items/:id/wrong_restock', to: 'items#wrong_restock', as: 'wrong_restock'

  get 'search', to: 'search#index', as: 'search'

  get 'batches', to: 'batches#index', as: 'batches'
  post 'batches', to: 'batches#create', as: 'create_batch'
  get 'batches/current', to: 'batches#current', as: 'current_batch'
  post 'batches/remove', to: 'batches#remove', as: 'remove_batch_match'
  get 'batches/retrieve', to: 'batches#retrieve', as: 'retrieve_batch'
  post 'batches/item', to: 'batches#item', as: 'item_batch'
  get 'batches/bin', to: 'batches#bin', as: 'bin_batch'
  post 'batches/scan_bin', to: 'batches#scan_bin', as: 'scan_bin_batch'
  get 'batches/finalize', to: 'batches#finalize', as: 'finalize_batch'
  post 'batches/finish', to: 'batches#finish', as: 'finish_batch'

  get 'batches/view/processed', to: 'batches#view_processed', as: 'view_processed_batches'
  get 'batches/view/processed/:id', to: 'batches#view_single_processed', as: 'view_single_processed_batch'

  get 'batches/view/active', to: 'batches#view_active', as: 'view_active_batches'
  get 'batches/view/active/:id', to: 'batches#view_single_active', as: 'view_single_active_batch'
  post 'batches/view/active', to: 'batches#cancel_single_active', as: 'cancel_single_active_batch'

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
