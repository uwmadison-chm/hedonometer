# -*- encoding : utf-8 -*-

Hedonometer::Application.routes.draw do
  get 'sessions/new'

  get 'welcome/index'

  root :to => 'welcome#index'

  resources :surveys, :only => [] do
    get  'login'   => 'session#new'
    post 'login'   => 'session#create'
    get  'logout'  => 'session#destroy'
    get  'send_login_code' => 'session#send_login_code'

    post 'message' => 'incoming_text_messages#create'
    get  '' => 'participants#edit', :as => '' # survey_path
    post '' => 'participants#update'
    patch '' => 'participants#update'

    resources :participants, only: [:create]
  end

  namespace :admin do
    root :to => 'welcome#index'

    resources 'surveys' do
      resources :participants
    end


    # Authn
    get  'login'  => 'session#new'
    post 'login'  => 'session#create'
    get  'logout' => 'session#destroy'
  end
end
