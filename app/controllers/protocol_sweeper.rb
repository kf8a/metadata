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
  
  private

  def expire_cache_for(datatable)
    expire_fragment(:controller => 'protocols', :action => 'show', :id => datatable )
    expire_fragment(:contoller => 'protocols',:action => 'index') 
  end
end
