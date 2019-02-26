Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
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

  # No auth, so links in text messages can be clicked easily
  resources :scheduled_messages
  get 'r(/:id)', to: 'scheduled_messages#show'

  namespace :admin do
    root :to => 'welcome#index'

    resources :surveys do
      resources :participants
    end

    resources :admins

    resource :twilio_account

    # Authn
    get  'login'  => 'session#new'
    post 'login'  => 'session#create'
    get  'logout' => 'session#destroy'
  end
end
