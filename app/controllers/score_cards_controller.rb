class ScoreCardsController < ApplicationController
  def index
    @datatables = Datatable.includes(:dataset).where(:is_sql => true).where('datasets.website_id = 1').limit(25).all
  end
end
