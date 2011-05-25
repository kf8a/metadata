class AuthorsController < ApplicationController

  def index
    @authors = Author.where("name like ?", "%#{params[:q]}%")
    respond_to do |format|
      format.json { render :json => @authors.map(&:attributes) }
    end
  end
end
