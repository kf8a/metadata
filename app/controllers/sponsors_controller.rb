class SponsorsController < ApplicationController
  
  def show
    @sponsor = Sponsor.find(params[:id])
  end
  
end
