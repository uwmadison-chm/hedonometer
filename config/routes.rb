Hedonometer::Application.routes.draw do
  get 'sessions/new'

  get 'welcome/index'

  root :to => 'welcome#index'

  resources :surveys do
    get 'login'  => 'session#new'
    post 'login' => 'session#create'
    get 'logout' => 'session#destroy'

    resources :participants, only: [:create] do
      post :send_login_code, on: :collection
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
