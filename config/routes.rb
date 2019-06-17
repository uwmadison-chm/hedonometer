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

  # No auth path for scheduled message survey redirects,
  # so links in text messages can be clicked easily
  get 'r/complete', to: 'scheduled_messages#complete'
  get 'r(/:id)', to: 'scheduled_messages#show', as: 'redirect'

  namespace :admin do
    root :to => 'welcome#index'

    resources :surveys do
      resources :participants do
        get 'simulate' => 'simulator#index'
        post 'simulate_send' => 'simulator#simulate_send'
        post 'simulate_reply' => 'simulator#simulate_reply'
        post 'simulate_timeout' => 'simulator#simulate_timeout'
        post 'simulate_reset' => 'simulator#simulate_reset'
      end
    end

    resources :admins

    get 'jobs' => 'jobs#index'
    get 'jobs/:kind' => 'jobs#view', :as => 'jobs_view'

    resource :twilio_account

    # Authn
    get  'login'  => 'session#new'
    post 'login'  => 'session#create'
    get  'logout' => 'session#destroy'
  end
end
