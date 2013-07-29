# -*- encoding : utf-8 -*-

Hedonometer::Application.routes.draw do
  get 'sessions/new'

  get 'welcome/index'

  root :to => 'welcome#index'

  resources :surveys do
    get 'login'  => 'session#new'
    post 'login' => 'session#create'
    get 'logout' => 'session#destroy'

    post 'message' => 'incoming_text_messages#create'

    resources :participants, only: [:create]
    resource :participant, only: [:edit, :update] do
      post :send_login_code
    end
  end

  namespace :admin do
    root :to => 'welcome#index'

    resources 'surveys'

    # Authn
    get 'login'   => 'session#new'
    post 'login'  => 'session#create'
    get 'logout'  => 'session#destroy'
  end
end
