class SponsorsController < ApplicationController
  
  def index
    @sponsor = Sponsor.find_by_name(website.name)
  end

  def show
    @sponsor = Sponsor.find(params[:id])
  end
  
end
