class CitationsController < ApplicationController
  layout :site_layout

  def index
    store_location
    @submitted_citations = Citation.submitted_with_authors_by_sur_name_and_pub_year
    @forthcoming_citations = Citation.forthcoming_with_authors_by_sur_name_and_pub_year
    @citations = Citation.published_with_authors_by_sur_name_and_pub_year
  end

  def show
    store_location
    @citation = Citation.find(params[:id])
  end
  
  def new
    head(:forbidden) and return unless signed_in? and current_user.role == 'admin'
    @citation = Citation.new
  end

  def create
    #short circuit if we are not going to process the request anyways
    head(:forbidden) and return unless signed_in? and current_user.role == 'admin'

    @citation = Citation.new(params[:citation])

    respond_to do |format|
      if @citation.save
        expire_action :action => :index
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

  def edit
    head(:forbidden) and return unless signed_in? and current_user.role == 'admin'
    @citation = Citation.find(params[:id]) 
  end
  
  def update
    head(:forbidden) and return unless signed_in? and current_user.role == 'admin'

    @citation = Citation.find(params[:id])

    respond_to do |format|
      if @citation.update_attributes(params[:citation])
        expire_action :action => :index
        format.html {redirect_to citation_url(@citation)}
        format.xml  { head :created, :location => citation_url(@citation) }
        format.json { head :created, :location => citation_url(@citation)}
      else
        format.html { render :action => 'new'}
        format.xml  { render :xml => @citation.errors.to_xml }
        format.json { render :json => @citation.errors.to_json }
      end
    end
  end
  
  def download
    head(:not_found) and return unless (citation = Citation.find_by_id(params[:id]))
    deny_access and return unless signed_in?
    
    logger.info  "USER: #{signed_in?}"
    path = citation.pdf.path(params[:style])
    if Rails.env.production? and signed_in?
      redirect_to(AWS::S3::S3Object.url_for(path, citation.pdf.bucket_name, :expires_in => 10.seconds))
    else
      send_file  path, :type => 'application/pdf', :disposition => 'inline'
    end
  end

  def destroy
    head(:forbidden) and return unless signed_in? and current_user.role == 'admin'

    citation = Citation.find(params[:id])
    citation.destroy 

    expire_action :action => :index
    respond_to do |format|
      format.html { redirect_to citations_url }
      format.xml  { head :ok }
    end
  end
  
  private 
  
  def set_title
     if request_subdomain(params[:requested_subdomain]) == "lter"
       @title  = 'LTER Publications'
     else
       @title = 'GLBRC Sustainability Publications'
     end
   end
end
