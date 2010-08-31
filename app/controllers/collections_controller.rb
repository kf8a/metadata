class CollectionsController < ApplicationController

  def index
    @collections = Collection.all
  end
  
  def show
    @collection = Collection.find(params[:id])
    @values = @collection.datatable.perform_query
  end
  
end
