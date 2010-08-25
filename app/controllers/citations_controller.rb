class CitationsController < ApplicationController
  layout :site_layout
  caches_action :index if RAILS_ENV == 'production'

  def index
    @citations = Citation.all(:order => 'pub_year desc')
    # subdomain_request = request_subdomain(params[:requested_subdomain])
    # page = nil
    # page = template_choose(subdomain_request, "datatables", "index")
    
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
        format.json { render :json => @citation.errors.to_json }
      end
    end
  end
  
  def download
    head(:not_found) and return unless (citation = Citation.find_by_id(params[:id]))
    head(:forbidden) and return unless signed_in? or RAILS_ENV == 'development'
    
    path = citation.pdf.path(params[:style])
    logger.info path
    send_file(path)
  end
  
  private 
  
  def set_title
     if request_subdomain(params[:requested_subdomain]) == "lter"
       @title  = 'LTER Publications'
     else
       @title = 'GLBRC Publications'
     end
   end
end
