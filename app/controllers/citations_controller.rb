class CitationsController < ApplicationController
  layout :site_layout
  caches_action :index if RAILS_ENV == 'production'

  def index
    @citations = Citation.all
  end

  def show
    @citation = Citation.find(params[:id])
  end
  
  def new
    @citation = Citation.new
  end

  def create
    #short circuit if we are not going to process the request anyways
    head(:forbidden) and return unless signed_in? and current_user.role == 'admin'

    @citation = Citation.new(params[:citation])

    respond_to do |format|
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
    end
  end
  
  def download
    head(:not_found) and return unless (citation = Citation.find_by_id(params[:id]))
    head(:forbidden) and return unless signed_in?
    
    path = citation.pdf.path(params[:style])
    send_file(path)
  end
end
