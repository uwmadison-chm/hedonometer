Hedonometer::Application.routes.draw do
  get 'sessions/new'

  get 'welcome/index'

  root :to => 'welcome#index'

  resources :surveys do
    resources :participants
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
