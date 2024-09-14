Rails.application.routes.draw do
    root "home#index"

    put "account", to: "users#update"

    post "sign_up", to: "users#create"
    post "login", to: "sessions#create"

    delete "logout", to: "sessions#destroy"
    delete "account", to: "users#destroy"

    get "sign_up", to: "users#new"
    get "login", to: "sessions#new"
    get "account", to: "users#edit"

    resources :confirmations, only: [:create, :edit, :new], param: :confirmation_token
    resources :passwords, only: [:create, :edit, :new, :update], param: :password_reset_token
    resources :active_sessions, only: [:destroy] do
        collection do
            delete "destroy_all"
        end
    end
end
