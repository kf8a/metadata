ActionController::Routing::Routes.draw do |map|
  
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
      
  Clearance::Routes.draw(map)
  
  map.resources :projects

  map.resources :weathers

  map.resources :affiliations

  map.connect 'people/alphabetical', :controller => 'people', :action => 'alphabetical', :requirements => { :method => :get }
  map.connect 'people/emeritus', :controller => 'people', :action => 'emeritus', :requirements => {:method => :get}
  map.connect 'people/show_all', :controller => 'people', :action => 'show_all'
  
  map.resources :people, :collection => {:alphabetical => :get,
                                         :emeritus => :get}

  map.resources :protocols

  map.resources :datasets, :collection => {:set_affiliation_for => :post,
                                           :auto_complete_for_keyword_list => :get}

  map.resources :datatables, :collection => {
                            :auto_complete_for_datatable_keyword_list => :get,
                            :events  => :get,
                            :suggest => :get,
                            :search  => :get,
                            :update_temporal_extent => :get
                            }

  map.resources :variates

  map.resources :publications, :collection => {:index_by_treatment => :get}
  
  map.resources :contacts
  
  map.resources :abstracts
  
  map.resources :meetings
  
  map.resources :units
  
  map.resources :themes
  
  map.resources :studies
  
  map.resources :templates
  
  map.resources :data_contributions
  
  map.resources :uploads
  
  map.resources :permissions
  
  map.resources :permission_requests
  
  map.resources :ownerships, :collection => {:add_another_user => :post,
                                             :add_another_datatable => :post}
  
  map.resources :citations, :collection => {:download => :get}
  
  map.resources :sponsors
  
  map.resources :collections, :collection => {:customize => :post}
  
  map.resources :pages
  
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

  # Install the default route as the lowest priority.
#  map.connect ':controller/:action/:id.:format'
#  map.connect ':controller/:action/:id'
end
