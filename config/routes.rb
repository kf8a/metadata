ActionController::Routing::Routes.draw do |map|
  
  map.send_invitation '/send_invitation/:id', :controller => "invites", :action => "send_invitation"
  map.redeem_invitation '/sign_up/:invite_code', :controller => 'users', :action => 'new'
  
  map.resource :session, :controller => 'sessions'
  map.resource :users, :controller => 'users'
    
  map.sign_in  'sign_in',
    :controller => 'sessions',
    :action     => 'new'
  map.sign_out 'sign_out',
    :controller => 'sessions',
    :action     => 'destroy',
    :method     => :delete

  map.sign_up  'sign_up',
    :controller => 'users',
    :action     => 'new'
      
  map.resources :abstracts
  
  map.resources :affiliations

  map.resources :citations, :only => [:index, :show, :new, :create],
                            :collection => {:download => :get}
  
  map.resources :collections, :only => [:index, :show],
                              :collection => {:customize => :post}
  
  map.resources :data_contributions, :only => [:new]
  
  map.resources :datasets, :collection => {
                           :set_affiliation_for => :post,
                           :auto_complete_for_keyword_list => :get,
                           :auto_complete_for_dataset_keyword_list => :get}

  map.resources :datatables, :collection => {
                            :auto_complete_for_datatable_keyword_list => :get,
                            :events  => :get,
                            :suggest => :get,
                            :search  => :get,
                            :update_temporal_extent => :get
                            }

  map.resources :invites

  map.resources :meetings

  map.resources :ownerships, :only => [:index, :new, :show, :create],
                             :collection => {:add_another_user      => :post,
                                             :add_another_datatable => :post,
                                             :revoke                => :delete}

  map.resources :pages

  map.resources :people, :collection => {:alphabetical  => :get,
                                         :emeritus      => :get,
                                         :show_all      => :get}

  map.resources :permissions, :except => [:edit, :update],
                              :collection => {:create => :any,
                                              :deny => :any}
  
  map.resources :permission_requests, :collection => {:create => :any}

  map.resources :projects

  map.resources :protocols

  map.resources :publications, :collection => {:index_by_treatment => :get}
  
  map.resources :sponsors, :only => [:show]
  
  map.resources :studies, :only => [:index, :edit, :update]
  
  map.resources :templates, :except => [:edit]
  
  map.resources :themes, :only => [:index, :create, :update]
  
  map.resources :units, :only => [:index, :edit, :update, :show]
  
  map.resources :uploads, :only => [:index, :new, :create, :show]

  map.resources :variates

  #route to handle pdf downloads
  map.connect '/assets/citations/:attachment/:id/:style/:basename.:extension', :controller => 'citations', :action => 'download', :requirements => { :method => :get }
  
  #route for application tests
  map.resources :foo, :controller => 'application_controller_test/foo', 
                        :collection => {
                          :alphabetical => :get,
                          :emeritus => :get,
                          :testadmin => :get, 
                          :testpagechoose => :get} if RAILS_ENV=='test'
      
  map.root :controller => 'datatables'

  Clearance::Routes.draw(map)
  
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
end
