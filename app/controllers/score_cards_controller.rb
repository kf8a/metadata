class ScoreCardsController < ApplicationController
  def index
    # @datatables = Study.includes(:datatables).where('datatables.is_sql is true').where(:code => 'MSCE')

    on_web   = params[:on_web] || true
    website  = params[:website] || 'lter'
    study_id = params[:study_id]

    if 'glbrc' == website.downcase
      @datatables = Datatable.includes(:dataset).where(is_sql: true).where('datasets.website_id = 2')
                             .where(:on_web => on_web).order(:study_id).order(:theme_id).order('datatables.id').references(:dataset)
    else
      @datatables = Datatable.includes(:dataset).where('is_sql is true').where('datasets.website_id = 1')
                              .where(:on_web => on_web).order(:study_id).order(:theme_id).order('datatables.id').references(:dataset)
      if study_id
        @datatables = @datatables.where(:study_id => study_id)
      end
    end
  end

  def show
    @datatable = Datatable.find(params[:id])
  end
end
