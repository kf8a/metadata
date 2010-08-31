class CollectionsController < ApplicationController

  def index
    @collections = Collection.all
  end
  
  def show
  end
  
end
