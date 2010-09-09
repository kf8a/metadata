class CollectionsController < ApplicationController

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
    @values = @collection.perform_query
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
    @customize = params[:custom]
    render 'show'
  end
  
end
