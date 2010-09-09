class CollectionsController < ApplicationController

  layout :site_layout

  def index
    @collections = Collection.all
  end
  
  def show
    @collection = Collection.find(params[:id])
    @values = @collection.perform_query
    @customize = false
  end

  def customize
    @collection = Collection.find(params[:id])
    @limitby = params[:limitby]
    if @limitby == params[:oldlimitby] || params[:oldlimitby].blank?
      @limit1 = params[:limit1]
      @limit2 = params[:limit2]
      @contains = params[:contains]
      @limitrange = []
    else
      @limit1 = nil
      @limit2 = nil
      @contains = nil
      @limitrange = []
    end
    @values = @collection.perform_query
    @values.each do |row|
      @limitrange << row[@limitby] if row[@limitby]
    end
    @limitrange.uniq!
    @limitrange.sort!
    @limitoptions = []
    @values.fields.each do |field|
      next if field == "id"
      @limitoptions << [field.titleize, field]
    end
    @limitoptions.sort!
    @sortby = params[:sortby]
    @sort_direction = params[:sort_direction]
    @values = @values.sort {|a,b| a[@sortby]<=>b[@sortby] rescue 0} if @sort_direction == "Ascending"
    @values = @values.sort {|a,b| b[@sortby]<=>a[@sortby] rescue 0} if @sort_direction == "Descending"
    @customize = params[:custom]
    render 'show'
  end
  
end
