Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations',
                                    invitations: 'users/invitations' }

  authenticated :user do
    root to: 'portfolios#index', as: :investor_root
  end

  root to: redirect('/users/sign_in')

  resources :accounts, :kpis,
    :portfolio_invitations, :notifications,
    :sharings, :reports

  resources :help, only: [:new]

  resources :burnrates do
    member do
      get :move
      post :update_entries
    end

    resources :accounts do
      member do
        post :undo_delete
      end
    end
    resources :kpis do
      member do
        post :undo_delete
      end
    end

    resources :reports
  end

  resources :portfolios do
    resources :notifications
    member do
      post :undo_delete
    end
  end

  resources :companies do
    resources :notifications
    resources :report_requests
    resources :transfer_ownerships
    resources :reports do
      collection do
        get :move
      end
    end
    resources :sharings do
      member do
        get :disable
        get :enable
        post :undo_recind
      end
    end
    member do
      post :undo_delete
      post :undo_remove
      put :move_portfolio
    end
  end
end
