class CitationsController < ApplicationController
  def index
    @citations = Citation.all
  end

  def show
    @citation = Citation.find(:params[:id])
  end

end
