class CitationsController < ApplicationController
  layout :site_layout
  caches_action :index if RAILS_ENV == 'production'

  def index
    @citations = Citation.all
  end

  def show
    @citation = Citation.find(params[:id])
  end

  def create
    @citation = Citation.new(params[:citation])

    respond_to do |format|
      if signed_in? and current_user.role == 'admin'
        if @citation.save

          expire_action :acton => :index
          flash[:notice] = 'Citation was successfully created.'
          format.html { redirect_to citation_url(@citation) }
          format.xml  { head :created, :location => citation_url(@citation) }
          format.json { head :created, :location => citation_url(@citation)}
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @citation.errors.to_xml }
          format.josn { render :json => @citation.errors.to_json }
        end
      else
        format.html { head :forbidden }
        format.xml  { head :forbidden }
        format.json { head :forbidden }
      end
    end
  end
end
