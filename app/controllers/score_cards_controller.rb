class ScoreCardsController < ApplicationController
  def index
    limit = params[:limit] || 25
    # @datatables = Study.includes(:datatables).where('datatables.is_sql is true').where(:code => 'MSCE')

    @datatables = Datatable.includes(:dataset).where(:is_sql => true).where('datasets.website_id = 1').limit(limit.to_i).all
  end
end
