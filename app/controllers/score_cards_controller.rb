class ScoreCardsController < ApplicationController
  def index
    # @datatables = Study.includes(:datatables).where('datatables.is_sql is true').where(:code => 'MSCE')

    on_web = params[:on_web] || true
    if 'glbrc' == website
      @datatables = Datatable.includes(:dataset).where(:is_sql => true).where('datasets.website_id = 2')
    else
      @datatables = Datatable.includes(:dataset).where(:is_sql => true).where('datasets.website_id = 1').where(:on_web => on_web).order(:study_id).order(:theme_id)
    end
  end
end
