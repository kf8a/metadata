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
    expire_fragment(:controller => 'citations', :action => 'index', :action_sufix => 'thesis')
    expire_fragment(:controller => 'citations', :action => 'index', :action_sufix => 'book')
    expire_fragment(:controller => 'citations', :action => 'index', :action_sufix => 'chapter')
    expire_fragment(:controller => 'citations', :action => 'index', :action_sufix => 'article')
    expire_fragment(:controller => 'citations', :action => 'index', :action_sufix => 'report')
    expire_fragment(:controller => 'citations', :action => 'index', :action_suffix => "citation_#{citation.id}")
    expire_fragment(:controller => 'citations', :action=> 'show', :id=>citation.id)
  end
end
