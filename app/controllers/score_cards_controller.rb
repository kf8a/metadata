class ScoreCardsController < ApplicationController
  def index
    # @datatables = Study.includes(:datatables).where('datatables.is_sql is true').where(:code => 'MSCE')

    on_web   = params[:on_web] || true
    status   = params[:status] || 'active'
    website  = params[:website] || 'lter'
    study_id = params[:study_id]

    if 'glbrc' == website
      @datatables = Datatable.includes(:dataset).where(:is_sql => true).where('datasets.website_id = 2')
    else
      @datatables = Datatable.includes(:dataset).where(:is_sql => true).where('datasets.website_id = 1')
                              .where(:on_web => on_web).where('datasets.status = ?', status)
                              .order(:study_id).order(:theme_id).order('datatables.id')
      if study_id
        @datatables = @datatables.where(:study_id => study_id)
      end
    end
  end

  def show
    @datatable = Datatable.find(params[:id])
  end
end
