class DatasetSweeper < ActionController::Caching::Sweeper
  observe Dataset

  def after_create(dataset)
    expire_cache_for(dataset)
    expire_table_cache_for(dataset)
  end

  def after_update(dataset)
   expire_cache_for(dataset) 
   expire_table_cache_for(dataset)
  end

  def after_destroy(dataset)
   expire_cache_for(dataset) 
   expire_table_cache_for(dataset)
  end

  private

  def expire_cache_for(dataset)
    expire_fragment(:controller => 'datasets', :action => 'index', :action_suffix => 'lter')
    expire_fragment(:controller => 'datasets', :action => 'index', :action_suffix => 'glbrc' )
  end

  def expire_table_cache_for(dataset)
    dataset.datatables.each do |table|
      expire_fragment(:controller => 'datatables', :action => 'index', :action_suffix => 'lter')
      expire_fragment(:controller => 'datatables', :action => 'index', :action_suffix => 'glbrc' )
      expire_fragment(:controller => 'datatables', :action => 'show',  :action_suffix => 'page', :id => datatable)
      expire_fragment(:controller => 'datatables', :action => 'show',  :action_suffix => 'data', :id => datatable)
      expire_fragment(:controller => 'datatables', :action => 'show', :id => datatable, :format => 'climdb')
      expire_action :controller => 'datatables', :action => 'show', :id => datatable, :format => 'csv'
      #expire_csv_cache(datatable)
    end
  end

end
