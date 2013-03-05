Hedonometer::Application.routes.draw do
  get 'bazola' => 'foo#new'

  get 'sessions/new'

  get 'welcome/index'

  root :to => 'welcome#index'
  
  namespace :admin do
    root :to => 'welcome#index'
    # Authn
    get 'login'   => 'session#new'
    post 'login'  => 'session#create'
    get 'logout'  => 'session#destroy'
  end
end
