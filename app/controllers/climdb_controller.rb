# This controller is here because climdb only allows one url
# per site, so i needed some way to aggreagte the different
# weather datasets on this side.
class ClimdbController < ApplicationController

  def index
    @lterws = Datatable.find(175)
    @coopws = Datatable.find(300)
    @kzoo   = Datatable.find(301)
  end
end
