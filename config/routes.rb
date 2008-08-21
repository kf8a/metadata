ActionController::Routing::Routes.draw do |map|
  map.resources :projects

  map.resources :weathers

  map.resources :affiliations

  map.connect 'people/alphabetical', :controller => 'people', :action => 'alphabetical', :requirements => { :method => :get }
  map.resources :people

  map.resources :protocols

  map.resources :datasets

  map.resources :datatables

  map.resources :variates

  map.resources :publications, :collection => {:index_by_treatment => :get}
  
  map.resources :contacts
  
  map.resources :meetings
  
  map.resources :units

  map.resources :meeting_abstracts
  
  map.root :controller => 'datasets'

  map.open_id_complete 'sessions', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.resource :sessions  
  
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
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
