class CollectionsController < ApplicationController
  #This controller allows searching and sorting of a datatable's data through
  #a "collection" of its data.

  layout :site_layout
  
  before_filter :get_collection, :only => [:show, :customize]

  def index
    @collections = Collection.all
  end
  
  def show
    @values = @collection.perform_query
    @customize = false
  end

  def customize
    set_limits(params)
    @sortby = params[:sortby]
    @sort_direction = params[:sort_direction]
    @values = set_values(@collection, @sort_direction, @sortby)
    set_limitrange(@values, @limitby)
    set_limitoptions(@values)
    @customize = params[:custom]
    render 'show'
  end
  
  private
  
  def get_collection
    @collection = Collection.find(params[:id])
  end

  def set_limits(params)
    @limitby = params[:limitby]
    if new_limitby?(@limitby, params[:oldlimitby])
      @limit_min = nil
      @limit_max = nil
      @contains = nil
    else
      @limit_min = params[:limit_min]
      @limit_max = params[:limit_max]
      @contains = params[:contains]
    end
  end

  def new_limitby?(limitby, oldlimitby)
    oldlimitby && limitby != oldlimitby
  end

  def set_limitrange(values, limitby)
    @limitrange = values.collect {|row| row[limitby]}
    @limitrange.compact!
    @limitrange.uniq!
    @limitrange.sort!
  end

  def set_limitoptions(values)
    @limitoptions = []
    values.fields.each do |field|
      next if field == "id"
      @limitoptions << [field.titleize, field]
    end
    @limitoptions.sort!
  end

  def sort_values(collection, direction, sortby)
    values = collection.perform_query
    values = values.sort {|a,b| a[sortby]<=>b[sortby] rescue 0} if direction == "Ascending"
    values = values.sort {|a,b| b[sortby]<=>a[sortby] rescue 0} if direction == "Descending"
  end
end
