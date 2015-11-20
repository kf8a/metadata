# encoding: utf-8
class CitationsController < ApplicationController
  protect_from_forgery except: :download

  respond_to :html, :xml, :json
  layout :site_layout
  before_filter :admin?, :only => [:new, :create, :edit, :update, :destroy] unless Rails.env == 'development'

  has_scope :by_type,   :as => :type
  has_scope :sorted_by, :as => :sort_by
  has_scope :by_date,   :as => :date

  def index
    store_location
    case params[:type]
    when 'article' 
      citations = [website.article_citations]
      @type = 'ArticleCitation'
    when 'book'
      citations = [website.citations.bookish]
      @type = 'BookCitation'
    when 'thesis'
      citations = [website.thesis_citations]
      @type = 'ThesisCitation'
    when 'report'
      citations = [website.report_citations]
      @type = 'ReportCitation'
    when 'bulletin'
      citations = [website.bulletin_citations]
      @type = 'BulletinCitation'
    else 
      @type = nil
      # citations = [website.article_citations, website.book_citations, website.chapter_citations, website.thesis_citations]
      citations = [website.citations.publications]
    end

    if params[:treatment]
      @study= Study.find(params[:treatment])
      citations = [Citation.from_website(website.id).by_treatment(params[:treatment])]
    end

    @submitted_citations = citations.collect {|c| c.submitted}.flatten
    @forthcoming_citations = citations.collect {|c| c.forthcoming}.flatten
    date = params[:date].presence
    @citations = date ? citations.collect {|c| c.by_date(date)}.flatten : citations.collect {|c| c.published}.flatten

    index_responder
  end

  def submitted 
      citations = [website.citations.publications]
      @citations = citations.collect {|c| c.submitted}.flatten
      index_responder
  end

  def index_by_treatment
    @studies = Study.by_id

    #@treatments  = Treatment.find(:all, :order => 'priority')
    respond_to do |format|
      format.html 
      format.xml {render  :xml => @studies.to_xml}
    end
  end

  def index_by_author
      citations = [website.citations.publications]
      @citations = citations.collect {|c| c.includes(:authors).references(:authors).published}.flatten.sort {|a,b| a.authors.first.try(:sur_name) <=> b.authors.first.try(:sur_name) }
      index_responder
  end

  def search
    @word = params[:word].sub(/\?|~|\\|\*|@|(?:=>)/, "")
    if @word.empty?
      redirect_to citations_url
    else
      @citations = Citation.search @word, with: { website_id: website.id }, order: "pub_year desc", star: true, per_page: 500
      index_responder
    end
  end

  def filtered
    @type = params[:type]
    @sort_by = params[:sort_by]
    @citations = apply_scopes(website.citations)
    @submitted_citations = @citations.submitted
    @forthcoming_citations = @citations.forthcoming
    @citations = @citations.published

    index_responder
  end

  def show
    @citation = Citation.find(params[:id].to_i)
    @website = website
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
    @citation.type = 'ArticleCitation'
  end

  def create
    citation_class = params[:citation].try(:delete, :type)
    @citation = website.citations.new(citation_params)
    @citation.type = citation_class
    flash[:notice] = 'Citation was successfully created.' if @citation.save

    respond_with @citation
  end

  def edit
    @citation = Citation.find(params[:id])
  end

  def update
    @citation = Citation.find(params[:id])
    @citation.type = params[:citation].try(:delete, 'type')
    @citation.update_attributes(citation_params)
    @citation.touch
    respond_with @citation, :location=>citation_url
  end

  def download
    head(:not_found) and return unless (citation = Citation.find_by_id(params[:id]))
    deny_access and return unless citation.open_access || signed_in?

    path = citation.pdf.path(params[:style])
    if Rails.env.production?
      if citation.open_access
        #TODO make this work accross domains not just with lter
        redirect_to("https://lter.kbs.msu.edu/open-access"+ citation.pdf.path.gsub(/ /, '+'))
        #redirect_to(citation.pdf.s3_object(params[:style]).public_url.to_s)
      else
        redirect_to(citation.pdf.s3_object(params[:style]).url_for(:read ,:secure => true, :expires_in => 10.seconds).to_s)
      end
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
    @citation = Citation.find(params[:id])
    @citation.destroy

    respond_with @citation, :location=>citations_url
  end

  private

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
      format.bib { send_data Citation.to_bib(@citations), :filename=>'glbdrc.bib' }
      format.rss { render :layout => false } #index.rss.builder
    end
  end

  def citation_params
    params.require(:citation).permit(:title, :abstract, :pub_date, :pub_year, :author_block,
                                    :citation_type_id, :address, :notes, :publication,
                                    :start_page_number, :ending_page_number, :periodical_full_name,
                                    :periodical_abbreviation, :volume, :issue, :city, :publisher,
                                    :secondary_title, :series_title, :isbn, :doi, :full_text,
                                    :publisher_url, :website_id, :pdf, :state, :open_access, :type,
                                    :has_lter_acknowledgement,:annotation, :data_url,
                                    datatable_ids: [], treatment_ids:[])
  end
end
