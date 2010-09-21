class CollectionsController < ApplicationController

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
    @values = @collection.perform_query
    set_limitrange(@values)
    set_limitoptions(@values)
    @sortby = params[:sortby]
    @sort_direction = params[:sort_direction]
    @values = sort_values(@values, @sort_direction, @sortby)
    @customize = params[:custom]
    render 'show'
  end
  
  private
  
  def get_collection
    @collection = Collection.find(params[:id])
  end

  def set_limits(params)
    @limitby = params[:limitby]
    if @limitby == params[:oldlimitby] || params[:oldlimitby].blank?
      @limit1 = params[:limit1]
      @limit2 = params[:limit2]
      @contains = params[:contains]
    else
      @limit1 = nil
      @limit2 = nil
      @contains = nil
    end
  end

  def set_limitrange(values)
    @limitrange = []
    values.each do |row|
      @limitrange << row[@limitby] if row[@limitby]
    end
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

  def sort_values(values, direction, sortby)
    values = values.sort {|a,b| a[sortby]<=>b[sortby] rescue 0} if direction == "Ascending"
    values = values.sort {|a,b| b[sortby]<=>a[sortby] rescue 0} if direction == "Descending"
    values
  end
end
