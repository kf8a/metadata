class CitationSweeper < ActionController::Caching::Sweeper
  observe Citation

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
    expire_fragment(:controller => 'citations', :action => 'index')
  end
end
