# frozen_string_literal: true

# Interface for sponsor display
class SponsorsController < ApplicationController
  def index
    @sponsor = Sponsor.find_by(name: website.name)
  end

  def show
    @sponsor = Sponsor.find(params[:id])
  end
end
