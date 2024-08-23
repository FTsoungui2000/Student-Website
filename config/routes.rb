Rails.application.routes.draw do
    root "home#index"

    post "sign_up", to: "users#create"
    post "login", to: "sessions#create"

    delete "logout", to: "sessions#destroy"

    get "sign_up", to: "users#new"
    get "login", to: "sessions#new"

    resources :confirmations, only: [:create, :edit, :new], param: :confirmation_token
    resources :passwords, only: [:create, :edit, :new, :update], param: :password_reset_token
end
