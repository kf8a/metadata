class CitationsController < ApplicationController
  respond_to :html, :xml, :json
  layout :site_layout
  cache_sweeper :citation_sweeper
  before_filter :admin?, :only => [:new, :create, :edit, :update, :destroy] unless Rails.env == 'development'
  before_filter :get_citation, :only => [:show, :edit, :update, :destroy]

  def index
    store_location
    citations = website.citations
    @submitted_citations = citations.submitted
    @forthcoming_citations = citations.forthcoming
    date = params[:date].presence
    @citations = date ? citations.by_date(date) : citations.published

    index_responder
  end

  def search
    @word = params[:word]
    if @word.empty?
      redirect_to citations_url
    else
      @citations = Citation.search @word, :with => { :website_id => website.id }
      index_responder
    end
  end

  def filtered
    @word, @type, @sort_by = params[:word], params[:type], params[:sort_by]
    @citations = website.citations.sorted_by(@sort_by).by_type(@type)
    @submitted_citations = @citations.submitted
    @forthcoming_citations = @citations.forthcoming
    date = params[:date].presence
    @citations = date ? @citations.by_date(date) : @citations.published

    index_responder
  end

  def show
    store_location
    file_title = @citation.file_title
    respond_to do |format|
      format.html
      format.enw { send_data @citation.to_enw, :filename => "#{file_title}.enw" }
      format.bib { send_data @citation.to_bib, :filename => "#{file_title}.bib" }
    end
  end

  def new
    @citation = Citation.new
  end

  def create
    citation_class = params[:citation].try(:delete, :type)
    @citation = website.citations.new(params[:citation])
    @citation.type = citation_class
    flash[:notice] = 'Citation was successfully created.' if @citation.save
    
    respond_with @citation
  end

  def edit
  end

  def update
    @citation.type = params[:citation].try(:delete, 'type')
    @citation.update_attributes(params[:citation])
    respond_with @citation
  end

  def download
    head(:not_found) and return unless (citation = Citation.find_by_id(params[:id]))
    deny_access and return unless citation.open_access || signed_in?

    path = citation.pdf.path(params[:style])
    if Rails.env.production? 
      redirect_to(AWS::S3::S3Object.url_for(path, citation.pdf.bucket_name, :expires_in => 10.seconds))
    else
      send_file  path, :type => 'application/pdf', :disposition => 'inline'
    end
  end

  def biblio
  end

  def bibliography
    date = params[:date].presence
    @citations = date ? Citation.by_date(date) : Citation.all
  end

  def destroy
    @citation.destroy

    respond_with @citation
  end

  private

  def get_citation
    @citation = Citation.find(params[:id])
  end

  def set_title
    if @subdomain_request == "lter"
      @title  = 'LTER Publications'
    else
      @title = 'GLBRC Sustainability Publications'
    end
  end
  
  def index_responder
    respond_to do |format|
      format.html
      format.enw { send_data Citation.to_enw(@citations), :filename=>'glbrc.enw' }
      format.bib { send_data Citation.to_bib(@citations), :filename=>'glbrc.bib' }
      format.rss { render :layout => false } #index.rss.builder
    end
  end
end
