class CitationSweeper < ActionController::Caching::Sweeper
  observe Citation

  def after_create(citation)
    expire_cache_for(citation)
  end

  def after_update(citation)
   expire_cache_for(citation) 
  end

  def after_destroy(citation)
   expire_cache_for(citation) 
  end

  private

  def expire_cache_for(citation)
    expire_fragment(:controller => 'citations', :action => 'index')
    expire_fragment(:controller=>'citations', :action=>'show', :id=>citation.id)
  end
end
