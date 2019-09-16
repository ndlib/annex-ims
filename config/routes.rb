# frozen_string_literal: true

Rails.application.routes.draw do
  resources :reports
  resources :tray_types do
    member do
      post 'activation'
    end
  end

  resources :dispositions do
    member do
      post 'activation'
    end
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end
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
  get 'trays/detail/:barcode', to: 'trays#tray_detail', as: 'tray_detail'
  post 'trays/items/:id', to: 'trays#associate_item', as: 'associate_tray_item'
  post 'trays/items/:id/dissociate', to: 'trays#dissociate_item', as: 'dissociate_tray_item'
  get 'trays/items/:id/missing', to: 'trays#missing', as: 'missing_tray_item'
  get 'trays/items/:id/invalid', to: 'trays#invalid', as: 'invalid_tray_item'
  post 'trays/items/:id/create', to: 'trays#create_item', as: 'create_tray_item'
  get 'trays/items/:id/count_items', to: 'trays#count_items', as: 'count_tray_item'
  post 'trays/items/:id/count_items', to: 'trays#count_items', as: 'validate_count_tray'

  get 'trays/check_items', to: 'trays#check_items_new', as: 'check_items_new'
  post 'trays/check_items', to: 'trays#check_items_find', as: 'check_items_find'
  get 'trays/check_items/:barcode', to: 'trays#check_items', as: 'check_items'
  post 'trays/check_items/:barcode', to: 'trays#validate_items', as: 'check_items_validate'

  post 'trays/:id/withdraw', to: 'trays#withdraw', as: 'withdraw_tray'

  get 'shelves/items', to: 'shelves#index', as: 'shelves'
  post 'shelves/items', to: 'shelves#scan', as: 'scan_shelf'
  get 'shelves/items/:id', to: 'shelves#show', as: 'show_shelf'
  get 'shelves/detail/:barcode', to: 'shelves#shelf_detail', as: 'shelf_detail'
  post 'shelves/items/:id', to: 'shelves#associate', as: 'associate_shelf_item'
  post 'shelves/items/:id/dissociate', to: 'shelves#dissociate', as: 'dissociate_shelf_item'
  get 'shelves/items/:id/wrong/:barcode', to: 'shelves#wrong', as: 'wrong_shelf_item'
  get 'shelves/items/:id/missing', to: 'shelves#missing', as: 'missing_shelf_item'

  get 'shelves/check_trays', to: 'shelves#check_trays_new', as: 'check_trays_new'
  post 'shelves/check_trays', to: 'shelves#check_trays_find', as: 'check_trays_find'
  get 'shelves/check_trays/:barcode', to: 'shelves#check_trays', as: 'check_trays'
  post 'shelves/check_trays/:barcode', to: 'shelves#validate_trays', as: 'check_trays_validate'

  get 'items', to: 'items#index', as: 'items'
  get 'items/scan', to: 'items#scan', as: 'scan_item'
  get 'items/issues', to: 'items#issues', as: 'issues'
  post 'items/resolve', to: 'items#resolve', as: 'resolve_issue'
  get 'trays/issues', to: 'trays#issues', as: 'trays_issues'
  post 'trays/resolve', to: 'trays#resolve', as: 'resolve_tray_issue'
  get 'items/:id', to: 'items#show', as: 'show_item'
  get 'items/detail/:barcode', to: 'items#item_detail', as: 'item_detail'
  post 'items/:id/restock', to: 'items#restock', as: 'item_restock'
  get 'items/:id/wrong_restock', to: 'items#wrong_restock', as: 'wrong_restock'
  post 'items/:barcode/refresh', to: 'items#refresh', as: 'item_refresh'

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

  get 'transfers/view/active', to: 'transfers#view_active', as: 'view_active_transfers'

  resources :transfers, only: %i[new create show] do
    member do
      put :scan_tray, as: 'scan_tray'
      delete :destroy, as: 'destroy'
      resources :trays, controller: 'transfers', only: [:transfer_tray] do
        put :transfer_tray, as: 'transfer'
      end
    end
  end

  get 'bins', to: 'bins#index', as: 'bins'
  get 'bins/:id', to: 'bins#show', as: 'show_bin'
  get 'bins/detail/:barcode', to: 'bins#bin_detail', as: 'bin_detail'
  post 'bins/remove_match', to: 'bins#remove_match', as: 'bin_remove'
  post 'bins/process_match', to: 'bins#process_match', as: 'bin_process'

  get 'reporting', to: 'reporting#index', as: 'reporting'
  get 'reporting/call_report', to: 'reporting#call_report', as: 'call_report'

  get 'users', to: 'users#index', as: 'users'
  put 'users', to: 'users#update', as: 'update_users'
  post 'users', to: 'users#create', as: 'create_users'

  resources :requests, only: [] do
    collection do
      post :sync
    end
    member do
      delete :remove
    end
  end

  get 'deaccessioning', to: 'deaccessioning#index', as: 'deaccessioning'
  post 'deaccessioning/req', to: 'deaccessioning#req', as: 'deaccessioning_req'

  get 'update', to: 'update#index', as: 'update'
  get 'old_update', to: 'update#old', as: 'old_update'
  get 'show_old_update', to: 'update#show_old', as: 'show_old_update'
  get 'show_existing_update', to: 'update#show_existing', as: 'show_existing_update'
  get 'new_update', to: 'update#new', as: 'new_update'
  get 'show_new_update', to: 'update#show_new', as: 'show_new_update'
  get 'merge_update', to: 'update#merge', as: 'merge_update'

  # You can have the root of your site routed with "root"
  root 'welcome#index'
end
