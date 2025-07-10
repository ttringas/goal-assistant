Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :goals do
        member do
          patch :complete
          patch :archive
        end
      end
      
      resources :progress_entries, only: [:index, :create, :update] do
        collection do
          get :today
        end
      end
      
      resources :ai_summaries, only: [:index, :show] do
        collection do
          get :today
        end
      end
    end
  end
end
