class ProtocolSweeper < ActionController::Caching::Sweeper
  observe Protocol

  def after_create(datatable)
    expire_cache_for(datatable)
  end

  def after_update(datatable)
   expire_cache_for(datatable) 
  end

  def after_destroy(datatable)
   expire_cache_for(datatable) 
  end

  def expire_index_cache
    expire_action(:controller => 'protocols', :action => 'index')
  end
  
  private

  def expire_cache_for(datatable)
    expire_index_cache
    expire_action(:controller => 'protocols', :action => 'show', :id => datatable )
  end
end
