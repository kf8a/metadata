class CitationsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :admin?, :only => [:new, :create, :edit, :update, :destroy]

  def index
    store_location
    @submitted_citations = Citation.submitted.sort_by_author_and_date
    @forthcoming_citations = Citation.forthcoming.sort_by_author_and_date
    if params[:date]
      @citations = Citation.by_date(params[:date])
    else
      @citations = Citation.published.sort_by_author_and_date
    end
    respond_to do |format|
      format.html
      format.enw do
        send_data @citations.collect {|x| x.as_endnote}.join("\n"), :filename=>'glbrc.enw'
      end
    end
  end

  def search
    @word = params[:word]
    @submitted_citations = Citation.submitted.by_word(@word).sort_by_author_and_date
    @forthcoming_citations = Citation.forthcoming.by_word(@word).sort_by_author_and_date
    if params[:date]
      @citations = Citation.by_word(@word).by_date(params[:date])
    else
      @citations = Citation.published.by_word(@word).sort_by_author_and_date
    end
    respond_to do |format|
      format.html
      format.enw do
        send_data @citations.collect {|x| x.as_endnote}.join("\n"), :filename=>'glbrc.enw'
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
