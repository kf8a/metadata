require 'customizer'

#This controller allows searching and sorting of a datatable's data through
#a "collection" of its data.
class CollectionsController < ApplicationController

  def index
    @collections = Collection.all
  end

  def show
    @collection = Collection.find(params[:id])
    @customizer = Customizer.new(params, @collection.values)
  end
end
