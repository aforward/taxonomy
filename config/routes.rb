ActionController::Routing::Routes.draw do |map|
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
  #map.connect ':controller/service.wsdl', :action => 'wsdl'
  map.connect '/', :controller => 'welcome', :action => 'consent'
  map.connect '/latest', :controller => 'taxonomy', :action => 'latest'
  map.connect '/taxonomy/list/:lookup', :controller => 'taxonomy', :action => 'list'
  map.connect '/taxonomy/build/:lookup', :controller => 'taxonomy', :action => 'build'
  map.connect '/taxonomy/evaluate/:lookup', :controller => 'taxonomy', :action => 'evaluate'
  map.connect '/taxonomy', :controller => 'taxonomy', :action => 'build'
  map.connect 'welcome', :controller => 'welcome', :action => 'consent'
  map.connect '/:controller/:action/:id'
end
