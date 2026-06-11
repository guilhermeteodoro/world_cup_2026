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
      post :agree
      post :withdraw
      post :cancel
    end

    resources :receipts, only: [ :update ] do
      collection do
        post :end_confirmation
      end
    end
  end

  resource :diff, only: [ :show, :create ]

  resources :anonymous_trades, only: [ :new, :create ]
end
