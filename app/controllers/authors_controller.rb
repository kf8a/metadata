class AuthorsController < ApplicationController
  #respond_to :json


  def new
    @author = Author.new
    respond_to do |format|
      format.js
    end
  end
end
