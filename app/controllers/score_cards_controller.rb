class ScoreCardsController < ApplicationController
  def index
    # @datatables = Study.includes(:datatables).where('datatables.is_sql is true').where(:code => 'MSCE')

    if 'glbrc' == website
      @datatables = Datatable.includes(:dataset).where(:is_sql => true).where('datasets.website_id = 2')
    else
      @datatables = Datatable.includes(:dataset).where(:is_sql => true).where('datasets.website_id = 1').order(:study_id)
    end
  end
end
