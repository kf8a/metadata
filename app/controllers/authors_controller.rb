class AuthorsController < ApplicationController

  def index
    @authors = Author.where("sur_name like ?", "%#{params[:q]}%")
    respond_to do |format|
      format.json { render :json => @authors.map(&:attributes) }
    end
  end
end
