class ScoreCardsController < ApplicationController
  def index
    limit = params[:limit] || 25
    @datatables = Datatable.includes(:dataset).where(:is_sql => true).where('datasets.website_id = 1').limit(limit.to_i).all
  end
end
