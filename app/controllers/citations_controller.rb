class CitationsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :admin?, :only => [:new, :create, :edit, :update, :destroy]

  def index
    store_location
    @submitted_citations = Citation.submitted.sort
    @forthcoming_citations = Citation.forthcoming.sort
    if params[:date]
      @citations = Citation.by_date(params[:date]).sort
    else
      @citations = Citation.published.sort
    end
    respond_to do |format|
      format.html
      format.enw do
        send_data Citation.to_enw(@citations), :filename=>'glbrc.enw'
      end
    end
  end

  def search
    @word, @type, @sort_by = params[:word], params[:type], params[:sort_by]
    citations = Citation.where(:type => @type).presence || Citation
    citations = citations.by_word(@word) if @word.present?
    @submitted_citations = citations.submitted.sorted_by(@sort_by)
    @forthcoming_citations = citations.forthcoming.sorted_by(@sort_by)
    if params[:date]
      @citations = citations.by_date(params[:date]).sorted_by(@sort_by)
    else
      @citations = citations.published.sorted_by(@sort_by)
    end
    respond_to do |format|
      format.html
      format.enw do
        send_data Citation.to_enw(@citations), :filename=>'glbrc.enw'
      end
    end
  end

  def show
    store_location
    @citation = Citation.find(params[:id])
    respond_to do |format|
      format.html
      format.enw do
        send_data @citation.as_endnote, :filename=>'glbrc.enw'
      end
    end
  end

  def new
    @citation = Citation.new
  end

  def create
    @citation = Citation.new(params[:citation])
    if @citation.save
      expire_action :action => :index
      flash[:notice] = 'Citation was successfully created.'
    end

    respond_with @citation
  end

  def edit
    @citation = Citation.find(params[:id])
  end

  def update
    @citation = Citation.find(params[:id])
    if @citation.update_attributes(params[:citation])
      expire_action :action => :index
    end

    respond_with @citation
  end

  def download
    head(:not_found) and return unless (citation = Citation.find_by_id(params[:id]))
    unless signed_in?
      deny_access and return
    end

    path = citation.pdf.path(params[:style])
    if Rails.env.production? and signed_in?
      redirect_to(AWS::S3::S3Object.url_for(path, citation.pdf.bucket_name, :expires_in => 10.seconds))
    else
      send_file  path, :type => 'application/pdf', :disposition => 'inline'
    end
  end

  def biblio
  end

  def bibliography
    if params[:date]
      @citations = Citation.by_date(params[:date])
    else
      @citations = Citation.all
    end
  end

  def destroy
    citation = Citation.find(params[:id])
    citation.destroy

    expire_action :action => :index
    respond_with citation
  end

  private

  def set_title
    if @subdomain_request == "lter"
      @title  = 'LTER Publications'
    else
      @title = 'GLBRC Sustainability Publications'
    end
  end
end
