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
    @customize = params[:custom]
    render 'show'
  end
  
end
