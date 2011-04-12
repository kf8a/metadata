class CitationsController < ApplicationController
  respond_to :html, :xml, :json
  layout :site_layout
  cache_sweeper :citation_sweeper
  before_filter :admin?, :only => [:new, :create, :edit, :update, :destroy] unless Rails.env == 'development'

  def index
    store_location
    citations = website.citations
    @submitted_citations = citations.submitted
    @forthcoming_citations = citations.forthcoming
    date = params[:date].presence
    @citations = date ? citations.by_date(date) : citations.published

    respond_to do |format|
      format.html
      format.enw { send_data Citation.to_enw(@citations), :filename=>'glbrc.enw' }
      format.bib { send_data Citation.to_bib(@citations), :filename=>'glbrc.bib' }
      format.rss { render :layout => false } #index.rss.builder
    end
  end

  def search
    @word = params[:word]
    if @word.empty?
      redirect_to citations_url
    else
      @citations = Citation.search @word, :with => { :website_id => website.id }
      respond_to do |format|
        format.html
        format.enw { send_data Citation.to_enw(@citations), :filename=>'glbrc.enw' }
        format.bib { send_data Citation.to_bib(@citations), :filename=>'glbrc.bib' }
        format.rss { render :layout => false } #index.rss.builder
      end
    end
  end

  def filtered
    @word, @type, @sort_by = params[:word], params[:type], params[:sort_by]
    citations = website.citations
    citations = citations.where(:type => @type) if @type.present?
    @submitted_citations = citations.submitted.sorted_by(@sort_by)
    @forthcoming_citations = citations.forthcoming.sorted_by(@sort_by)
    date = params[:date].presence
    @citations = date ? citations.by_date(date) : citations.published
    @citations.sorted_by(@sort_by)

    respond_to do |format|
      format.html
      format.enw { send_data Citation.to_enw(@citations), :filename=>'index.enw' }
      format.bib { send_data Citation.to_bib(@citations), :filename=>'index.bib' }
      format.rss { render :layout => false } #index.rss.builder
    end
  end

  def show
    store_location
    @citation = Citation.find(params[:id])
    respond_to do |format|
      format.html
      format.enw { send_data @citation.as_endnote, :filename=>"#{@citation.id}-#{@citation.title}-#{@citation.pub_year}.enw" }
      format.bib { send_data @citation.as_bibtex, :filename=>"#{@citation.id}-#{@citation.title}-#{@citation.pub_year}.bib" }
    end
  end

  def new
    @citation = Citation.new
  end

  def create
    @citation = website.citations.new(params[:citation])

    respond_to do |format|
      if @citation.save
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
    @citation = Citation.find(params[:id])
  end

  def update
    @citation = Citation.find(params[:id])
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
    citation = Citation.find(params[:id])
    citation.destroy

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
