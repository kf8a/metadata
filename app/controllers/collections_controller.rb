#This controller allows searching and sorting of a datatable's data through
#a "collection" of its data.
class CollectionsController < ApplicationController

  layout :site_layout
  
  def index
    @collections = Collection.all
  end
  
  def show
    @collection = Collection.find(params[:id])
    @customizer = Customizer.new(params, @values)
  end

  private
  
  def get_collection

  end

  def set_values

  end
end