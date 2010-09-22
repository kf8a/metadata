#This controller allows searching and sorting of a datatable's data through
#a "collection" of its data.
class CollectionsController < ApplicationController

  layout :site_layout
  
  before_filter :get_collection, :only => [:show, :customize]
  before_filter :set_values, :only => [:show, :customize]

  def index
    @collections = Collection.all
  end
  
  def show
    @customize = false
  end

  def customize
    set_limitoptions(@values)
    set_limits(params)
    @sortby = params[:sortby]
    @sort_direction = params[:sort_direction]
    @values = sort_values(@values, @sort_direction, @sortby)
    set_limitrange(@values, @limitby)

    @customize = params[:custom]
    render 'show'
  end
  
  private
  
  def get_collection
    @collection = Collection.find(params[:id])
  end

  def new_limitby?(limitby, oldlimitby)
    oldlimitby && limitby != oldlimitby
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

  def set_limitoptions(values)
    @limitoptions = values.fields.collect do |field|
      next if field == "id"
      [field.titleize, field]
    end
    @limitoptions = normalize(@limitoptions)
  end

  def set_limitrange(values, limitby)
    @limitrange = values.collect {|row| row[limitby]}
    @limitrange = normalize(@limitrange)
  end

  def set_values
    @values = @collection.perform_query
  end

  def sort_values(values, direction, sortby)
    values = values.sort {|a,b| a[sortby]<=>b[sortby] rescue 0} if direction == "Ascending"
    values = values.sort {|a,b| b[sortby]<=>a[sortby] rescue 0} if direction == "Descending"
    values
  end

  def normalize(array)
    array.compact!
    array.uniq!
    array.sort!
  end
end
