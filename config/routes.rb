# frozen_string_literal: true

Rails.application.routes.draw do
  root "pages#home"

  resource :registration, only: [ :new, :create ]
  resource :session, only: [ :new, :create, :destroy ]

  resources :users, path: "u", param: :slug, only: [ :show, :edit, :update ] do
    resource :collection, path: "c", only: [ :edit, :update ]
    resources :user_stickers, path: "album", only: [ :create, :update, :destroy ]
    resources :trades, only: [ :create ]
  end

  resources :trades, only: [] do
    member do
      get :export
    end
  end

  resource :diff, only: [ :show, :create ]

  get "up" => "rails/health#show", as: :rails_health_check
end
