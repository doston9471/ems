# frozen_string_literal: true

Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  get "/auth/:provider/callback", to: "omniauth_callbacks#create"
  post "/auth/:provider/callback", to: "omniauth_callbacks#create"
  get "/auth/failure", to: "omniauth_callbacks#failure"

  resource :email_verification, only: %i[show create]
  resource :mfa, only: %i[show create destroy], controller: "mfa"
  resource :mfa_challenge, only: %i[new create]

  get "up" => "rails/health#show", as: :rails_health_check
  get "/api-docs", to: "api_docs#show", as: :api_docs
  get "/api-docs/openapi.yaml", to: "api_docs#openapi", as: :api_docs_openapi

  root "dashboard#show"

  post "/graphql", to: "graphql#execute"

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  resources :employees, except: :destroy
  resources :departments

  namespace :attendance do
    resources :days, only: :index do
      collection do
        post :clock_in
        post :clock_out
        post :break_start
        post :break_end
      end
    end
  end

  resources :leave_requests, only: %i[index show new create] do
    member do
      post :approve
      post :reject
    end
  end

  resources :review_cycles, only: %i[index show new create] do
    member do
      post :assign_reviews
      post :close
    end
  end
  resources :performance_reviews, only: %i[index show] do
    member do
      post :submit
    end
  end
  resources :goals, only: %i[index new create]

  resources :offices
  resources :teams
  resources :timesheets, only: :index do
    member do
      post :approve
      post :reject
    end
  end
  resources :custom_field_definitions, except: :show
  resource :company_switcher, only: :create, controller: "company_switcher"

  namespace :my do
    resource :dashboard, only: :show, controller: "dashboard"
    resource :attendance, only: :show, controller: "attendance" do
      post :clock_in
      post :clock_out
      post :break_start
      post :break_end
    end
    resources :leave_requests, only: %i[index show new create]
    resources :performance_reviews, only: %i[index show] do
      member do
        post :submit
      end
    end
    resources :payslips, only: %i[index show]
    resource :objectives, only: :show, controller: "objectives"
    resources :documents, only: %i[index show]
    resources :assets, only: :index
    resource :team, only: :show, controller: "team"
    resource :upcoming, only: :show, controller: "upcoming"
    resources :emergency_contacts, except: :show
    resource :notification_preferences, only: %i[edit update], controller: "notification_preferences"
    resources :notifications, only: %i[index] do
      member do
        post :mark_read
      end
      collection do
        post :mark_all_read
      end
    end
  end

  resources :company_assets, only: %i[index show new create] do
    member do
      post :assign
      post :return_asset
    end
  end

  resources :employee_documents, only: %i[index show new create] do
    member do
      post :upload_version
    end
  end

  resources :notifications, only: :index
  resources :reports, only: :index
  get "reports/employees", to: "reports#employees_export", as: :reports_employees
  resource :search, only: :show, controller: "searches"
  resource :org_chart, only: :show
  resources :feature_flags, only: %i[index update]

  resources :payroll_runs, only: %i[index show new create]
  resources :payroll_items, only: :show
  resources :applicants, only: %i[index show new create update] do
    member do
      post :hire
    end
    resources :interviews, only: %i[create]
  end
  resources :audit_logs, only: :index

  match "/sso/:provider/initiate", to: "sso#initiate", via: %i[get post], as: :sso_initiate
  match "/sso/:provider/callback", to: "sso#callback", via: %i[get post], as: :sso_callback
  resources :calendar_connections, only: %i[index create update destroy]
  resources :calendar_events, only: :index
  get "/calendar_oauth/:provider/initiate", to: "calendar_oauth#initiate", as: :calendar_oauth_initiate
  get "/calendar_oauth/:provider/callback", to: "calendar_oauth#callback", as: :calendar_oauth_callback
  resource :company_settings, only: %i[edit update]

  namespace :api do
    namespace :v1 do
      post "session", to: "sessions#create"
      resources :employees, only: %i[index show]
      resources :departments, only: :index
      post "attendance/clock_in", to: "attendance#clock_in"
      post "attendance/clock_out", to: "attendance#clock_out"
      resources :leave_requests, only: :create
      resources :webhooks, except: %i[new edit]
      namespace :scim do
        get "Users", to: "users#index"
        post "Users", to: "users#create"
        get "Users/:id", to: "users#show"
        match "Users/:id", to: "users#update", via: %i[put patch]
        delete "Users/:id", to: "users#destroy"
      end
    end
  end
end
