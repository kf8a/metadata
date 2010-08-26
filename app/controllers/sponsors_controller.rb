class SponsorsController < ApplicationController
  
  layout :site_layout
  
  def show
    @sponsor = Sponsor.find(params[:id])
  end
  
end
