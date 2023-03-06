# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root "tiny_urls#index"
  resources :tiny_urls, only: %i[index create show]
  get "/:short_url", to: "tiny_urls#redirect", as: :redirect
end
