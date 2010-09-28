#This controller allows searching and sorting of a datatable's data through
#a "collection" of its data.
class CollectionsController < ApplicationController

  layout :site_layout
  
  before_filter :get_collection, :only => :show
  before_filter :set_values, :only => :show

  def index
    @collections = Collection.all
  end
  
  def show
    @customizer = Customizer.new(params, @values)
    @values = @customizer.sort_values(@values)
  end

  private
  
  def get_collection
    @collection = Collection.find(params[:id])
  end

  def set_values
    @values = @collection.perform_query
  end
end