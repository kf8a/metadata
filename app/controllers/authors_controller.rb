# frozen_string_literal: true

# list all of the authors as a debugging aid
class AuthorsController < ApplicationController
  def index
    @authors = Author.where('sur_name like ?', "%#{params[:q]}%")
    respond_to { |format| format.json { render json: @authors.map(&:attributes) } }
  end
end
