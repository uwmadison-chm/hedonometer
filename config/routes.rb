Hedonometer::Application.routes.draw do
  get 'bazola' => 'foo#new'

  get 'sessions/new'

  get 'welcome/index'

  root :to => 'welcome#index'
  
  namespace :admin do
    root :to => 'welcome#index'
    get 'login' => 'session#new'
    get 'logout' => 'session#destroy'
  end
end
