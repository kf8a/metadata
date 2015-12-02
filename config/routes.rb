Metadata::Application.routes.draw do

  match '/send_invitation/:id' => 'invites#send_invitation', :as => :send_invitation, via: [:get]
  match '/signup/:invite_code' => 'users#new', :as => :redeem_invitation, via: [:get]
  resource :session, :controller => 'sessions'
  resource :users

  resources :abstracts do
    member do
      get :download
    end
  end
  resources :affiliations

  resources :citations do
    member do
      get 'download/*filename', to: 'citations#download'
      get :download
    end
    collection do
      get :biblio
      get :search
      get :find_by_doi
      get :filtered
      get :submitted
      get :index_by_treatment
      get 'index_by_treatment/:treatment', :action => :index
      get :index_by_author
      get :index_by_type
      get 'index_by_type/:type', :action => :index
    end
  end

  resources :climdb, :only=> :index  # since climdb can only handle one url per site
  resources :authors
  resources :collections
  resources :data_contributions
  resources :dataset_files, :only => :show
  resources :datasets do
    collection do
      post :set_affiliation_for
    end
  end
  match 'knb/*id' => 'datasets#knb', via: [:get]

  resources :datatables do
    collection do
      get :auto_complete_for_datatable_keyword_list
      get :suggest
      post :search
    end
    member do
      get :qc
      get :update_temporal_extent
      post :approve_records
      put :publish
    end
  end
  resources :invites
  resources :meetings
  resources :ownerships do
    collection do
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
      put :deny
    end
  end
  resources :permission_requests, :only => :create
  resources :projects
  resources :protocols do
    member do
      get :download
    end
  end

  resources :sponsors, :as => 'termsofuse'
  match '/termsofuse/:id' => "sponsors#show", via: [:get]
  match '/termsofuse' => 'sponsors#index', via: [:get]

  post '/studies/:id/move_to/:parent_id' => 'studies#move_to'
  post '/studies/:id/move_before/:parent_id' => 'studies#move_before'
  resources :studies
  resources :templates

  post '/themes/:id/move_to/:parent_id' => 'themes#move_to'
  post '/themes/:id/move_before/:parent_id' => 'themes#move_before'
  resources :themes
  resources :units
  resources :uploads
  resources :variates

  resources :visualizations, :only => 'show'
  resources :score_cards, :only => ['index', 'show']

  root :to => 'datatables#index'

  if Rails.env == 'test'
    match 'application_controller_test/foo/testadmin' => 'application_controller_test/foo#testadmin', via: [:get]
    match 'application_controller_test/foo/testpagechoose' => 'application_controller_test/foo#testpagechoose', via: [:get]
    match 'application_controller_test/foo/alphabetical' => 'application_controller_test/foo#alphabetical', via: [:get]
    match 'application_controller_test/foo/emeritus' => 'application_controller_test/foo#emeritus', via: [:get]
  end
end
