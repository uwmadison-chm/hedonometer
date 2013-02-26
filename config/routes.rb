Hedonometer::Application.routes.draw do
  get "sessions/new"

  get "welcome/index"

  root :to => 'welcome#index'
  
  namespace :admin do
    root :to => "welcome#index"
    
  end
end
