# frozen_string_literal: true

Rails.application.routes.draw do
  root "pages#home"

  resource :registration, only: [ :new, :create ]
  resource :session, only: [ :new, :create, :destroy ]

  resources :users, path: "u", param: :slug, only: [ :show, :edit, :update ] do
    resource :collection, path: "c", only: [ :edit, :update ]
    resources :user_stickers, path: "album", only: [ :create, :update, :destroy ] do
      collection do
        post :glue_all
      end
    end
    resources :trades, only: [ :create ]
  end

  resources :trades, only: [ :index, :show, :update ] do
    member do
      get :export
      post :accept
      post :cancel
      post "trade_stickers/:trade_sticker_id/confirm_receipt", action: :confirm_receipt, as: :confirm_receipt
      post :confirm_all_receipts
    end
  end

  resource :diff, only: [ :show, :create ]

  get "up" => "rails/health#show", as: :rails_health_check
end
