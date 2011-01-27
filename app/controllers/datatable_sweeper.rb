class DatatableSweeper < ActionController::Caching::Sweeper
  observe Datatable

  def after_create(datatable)
    expire_cache_for(datatable)
    expire_related_table_cache_for(datatable)
  end

  def after_update(datatable)
   expire_cache_for(datatable) 
   expire_related_table_cache_for(datatable)
  end

  def after_destroy(datatable)
   expire_cache_for(datatable) 
   expire_related_table_cache_for(datatable)
  end

  private

  def expire_cache_for(datatable)
    expire_fragment(:controller => 'datatables', :action => 'index', :action_suffix => 'lter')
    expire_fragment(:controller => 'datatables', :action => 'index', :action_suffix => 'glbrc' )
    expire_fragment(:controller => 'datatables', :action => 'show',  :action_suffix => 'page', :id => datatable)
    expire_fragment(:controller => 'datatables', :action => 'show',  :action_suffix => 'data', :id => datatable)
    expire_action(:controller => 'datatables', :action => 'show', :id => datatable, :format => 'csv')
  end

  def expire_related_table_cache_for(datatable)
    datatable.dataset.datatables.each do |d|
      expire_cache_for(d)
    end
  end
end
