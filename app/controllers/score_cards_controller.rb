class ScoreCardsController < ApplicationController
  def index
    on_web   = params[:on_web] || true
    website  = params[:website] || 'lter'
    study_id = params[:study_id]

    if website.casecmp('glbrc')
      @datatables = glbrc_datatables(on_web)
    else
      @datatables = datatables(on_web)
      if study_id
        @datatables = @datatables.where(study_id: study_id)
      end
    end
  end

  def show
    @datatable = Datatable.find(params[:id])
  end

  private

  def glbrc_datatables(on_web)
    Datatable.includes(:dataset)
             .where(is_sql: true)
             .where('datasets.website_id = 2')
             .where(on_web: on_web)
             .order(:study_id)
             .order(:theme_id).order('datatables.id')
             .references(:dataset)
  end

  def datatables(on_web)
    Datatable.includes(:dataset)
             .where('is_sql is true')
             .where('datasets.website_id = 1')
             .where(on_web: on_web)
             .order(:study_id)
             .order(:theme_id)
             .order('datatables.id')
             .references(:dataset)
  end
end
