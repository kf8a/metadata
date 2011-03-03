Metadata::Application.routes.draw do
  match '/send_invitation/:id' => 'invites#send_invitation', :as => :send_invitation
  match '/signup/:invite_code' => 'users#new', :as => :redeem_invitation
  resource :session, :controller => 'sessions'
  resource :users
  match 'sign_in' => 'sessions#new', :as => :sign_in
  match 'sign_out' => 'sessions#destroy', :as => :sign_out
  match 'sign_up' => 'users#new', :as => :sign_up
  resources :abstracts
  resources :affiliations


  resources :citations do
    member do
      get :download
    end
    collection do
      get :biblio
      get :search
    end
  end

  resources :authors
  resources :collections
  resources :data_contributions
  resources :datasets do
    collection do
      post :set_affiliation_for
    end
  end
  resources :datatables do
    collection do
      get :auto_complete_for_datatable_keyword_list
      get :events
      get :suggest
      post :search
      get :update_temporal_extent
    end
  end
  resources :invites
  resources :meetings
  resources :ownerships do
    collection do
      post :add_another_user
      post :add_another_datatable
      delete :revoke
    end
  end
  resources :pages
  resources :people do
    collection do
      get :alphabetical
      get :emeritus
      get :show_all
    end
  end
  resources :permissions do
    collection do
      post :create
      put :deny
    end
  end
  resources :permission_requests do
    collection do
      post :create
    end
  end
  resources :projects
  resources :protocols
  resources :publications do
    collection do
      get :index_by_treatment
    end
  end
  resources :sponsors
  resources :studies
  resources :templates
  resources :themes
  resources :units
  resources :uploads
  resources :variates

  match "/application.manifest" => Rails::Offline

  root :to => 'datatables#index'
  match ':controller/service.wsdl' => '#wsdl'

  if Rails.env == 'test'
    match 'application_controller_test/foo/testadmin' => 'application_controller_test/foo#testadmin'
    match 'application_controller_test/foo/testpagechoose' => 'application_controller_test/foo#testpagechoose'
    match 'application_controller_test/foo/alphabetical' => 'application_controller_test/foo#alphabetical'
    match 'application_controller_test/foo/emeritus' => 'application_controller_test/foo#emeritus'
  end
end
