# frozen_string_literal: true

Rails.application.routes.draw do
  resources :events, only: %i[index show], defaults: { format: :json } do
    member do
      get :tickets
      post :buy_ticket
    end
  end
end
