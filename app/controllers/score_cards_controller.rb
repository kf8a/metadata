class ScoreCardsController < ApplicationController
  def index
    # @datatables = Study.includes(:datatables).where('datatables.is_sql is true').where(:code => 'MSCE')

    @datatables = Datatable.includes(:dataset).where(:is_sql => true)
  end
end
