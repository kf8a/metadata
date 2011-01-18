class PeopleSweeper < ActionController::Caching::Sweeper
  observe Person
  
  def after_create(person)
    expire_cache_for(person)
  end
  
  def after_update(person)
    expire_cache_for(person)
  end
  
  def after_destroy(person)
    expire_cache_for(person)
  end
  
  private
  def expire_cache_for(record)
    expire_action :action => :index
    expire_action :action => :emeritus
    expire_action :action => :alphabetical
  end
end
