class ProtocolSweeper < ActionController::Caching::Sweeper
  observe Protocol

  def after_create(protocol)
    expire_cache_for(protocol)
    expire_cache_for_linked_datatables(protocol)
  end

  def after_update(protocol)
   expire_cache_for(protocol) 
   expire_cache_for_linked_datatables(protocol)
  end

  def after_destroy(protocol)
   expire_cache_for(protocol) 
   expire_cache_for_linked_datatables(protocol)
  end
  
  private

  def expire_cache_for(protocol)
    expire_fragment(:controller => 'protocols', :action => 'show', :id => protocol )
    expire_fragment(:controller => 'protocols', :action => 'index') 
  end

  def expire_cache_for_linked_datatables(protocol)
    protocol.datatables.each do |datatable|
      expire_fragment(:controller => 'datatables', :action=>'show', :id=>datatable)
    end 
    #protocol.dataset.datatables.each do |datatable|
    #  expire_fragment(:controller => 'datatables', :action=>'show', :id=>datatable)
    #end
  end
end
