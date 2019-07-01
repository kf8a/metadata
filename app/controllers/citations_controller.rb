# frozen_string_literal: true

# display citations and control access to pdfs
class CitationsController < ApplicationController
  include FileSource

  protect_from_forgery except: :download

  respond_to :html, :json
  layout :site_layout
  before_action :authenticate_user!, except: \
    %i[index show search index_by_doi index_by_treatment download filtered]
  before_action :admin?, only: %i[new create edit update destroy]

  has_scope :by_type,   as: :type
  has_scope :sorted_by, as: :sort_by
  has_scope :by_date,   as: :date

  def index
    store_location_for(:user, citations_path)
    # Try to remove extra null bytes from user submitted strings
    citations = citations_by_type(params[:type])

    if params[:treatment]
      @treatment = Treatment.find(params[:treatment].to_i)
      @study = @treatment.study
      @treatment = nil unless @study.citation_treatments?
      citations = [Citation.from_website(website.id).by_treatment(params[:treatment])]
    end

    @submitted_citations = citations.collect(&:submitted).flatten
    @forthcoming_citations = citations.collect(&:forthcoming).flatten
    date = params[:date].presence
    @citations = date ? citations.collect { |c| c.by_date(date) } : citations.collect(&:published)
    @citations.flatten!

    index_responder_for_type(@type)
  end

  def submitted
    citations = [website.citations.publications]
    @citations = citations.collect(&:submitted).flatten
    index_responder
  end

  def index_by_treatment
    @studies = Study.by_weight.by_id

    # @treatments  = Treatment.find(:all, order: 'priority')
    respond_to do |format|
      format.html
      format.xml { render xml: @studies.to_xml }
    end
  end

  def _author_sorter(first, second)
    first.authors.first.try(:sur_name) <=> second.authors.first.try(:sur_name)
  end

  def index_by_author
    citations = [website.citations.publications]
    @citations = citations.collect { |c| c.includes(:authors).references(:authors).published }
                          .flatten.sort { |a, b| _author_sorter(a, b) }

    index_responder
  end

  def index_by_doi
    @citations = [website.citations.where('doi is not null').publications]
    index_responder
  end

  def search
    @word = params[:q] || ''
    if @word.present?
      @word = SearchInputSanitizer.sanitize(@word)
      search_terms = assemble_search_terms(@word)

      @citations = Citation.search(search_terms, with: { website_id: website.id },
                                                 order: 'pub_year ASC',
                                                 per_page: 500)
      logger.info Citation.search(search_terms)
      index_responder
    else
      redirect_to citations_url
    end
  end

  def find_by_doi
    @citation = CitationFactory.from_doi(params[:doi])
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
    store_location_for(:user, params[:id].to_i)
    file_title = @citation.file_title
    respond_to do |format|
      format.html
      format.enw { send_data @citation.to_enw, filename: "#{file_title}.enw" }
      format.bib { send_data @citation.to_bib, filename: "#{file_title}.bib" }
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
    @citation.update(citation_params)
    @citation.touch
    respond_with @citation, location: citation_url
  end

  def download
    head(:not_found) && return unless (citation = Citation.find_by(id: params[:id]))
    deny_access && return unless citation.open_access || signed_in?

    send_citation(citation)
  end

  def biblio; end

  def bibliography
    date = params[:date].presence
    @citations = date ? Citation.by_date(date) : Citation.all
  end

  def destroy
    @citation = Citation.find(params[:id])
    @citation.destroy

    respond_with @citation, location: citations_url
  end

  private

  def send_citation(citation)
    if citation.open_access
      from_open_access(citation)
    else
      from_standard_access(citation)
    end
  end

  def from_open_access(citation)
    # TODO: make this work accross domains not just with lter
    redirect_to('https://lter.kbs.msu.edu/open-access' + citation.pdf.path.tr(' ', '+'))
    # redirect_to(citation.pdf.s3_object(params[:style]).public_url.to_s)
  end

  def from_standard_access(citation)
    file_from_s3(citation.pdf)
  end

  def set_title
    @title = if @subdomain_request == 'lter'
               'LTER Publications'
             else
               'GLBRC Sustainability Publications'
             end
  end

  def index_responder
    index_responder_for_type('article')
  end

  def index_responder_for_type(type)
    respond_to do |format|
      format.html { render template: template_for_type(type) }
      format.enw { send_data Citation.to_enw(@citations), filename: 'glbrc.enw' }
      format.bib { send_data Citation.to_bib(@citations), filename: 'glbdrc.bib' }
      format.rss { render layout: false } # index.rss.builder
    end
  end

  Templates = { 'ArticleCitation'  =>  'citations/article_citations',
                'BookCitation'     =>  'citations/book_citations',
                'ThesisCitation'   =>  'citations/thesis_citations',
                'ReportCitation'   =>  'citations/report_citations',
                'BulletinCitation' =>  'citations/bulletin_citations',
                'DataCitation'     =>  'citations/data_citations' }.freeze

  def template_for_type(type)
    logger.info "type #{type}"
    Templates.fetch(type, 'citations/article_citations')
  end

  def citation_params
    params.require(:citation).permit(:title, :abstract, :pub_date, :pub_year, :author_block,
                                     :citation_type_id, :address, :notes, :publication,
                                     :editor_block,
                                     :start_page_number, :ending_page_number, :periodical_full_name,
                                     :periodical_abbreviation, :volume, :issue, :city, :publisher,
                                     :secondary_title, :series_title, :isbn, :doi, :full_text,
                                     :publisher_url, :website_id, :pdf, :state, :open_access, :type,
                                     :has_lter_acknowledgement, :annotation, :data_url,
                                     datatable_ids: [], treatment_ids: [])
  end

  def citations_by_type(type)
    case type
    when 'article'
      @type = 'ArticleCitation'
      [website.article_citations]
    when 'book'
      @type = 'BookCitation'
      [website.citations.bookish]
    when 'thesis'
      @type = 'ThesisCitation'
      [website.thesis_citations]
    when 'report'
      @type = 'ReportCitation'
      [website.report_citations]
    when 'bulletin'
      @type = 'BulletinCitation'
      [website.bulletin_citations]
    when 'data'
      @type = 'DataCitation'
      [website.data_citations]
    else
      @type = nil
      [website.citations.publications]
    end
  end

  def assemble_search_terms(word)
    terms = word.split(/ /)
    terms.collect do |term|
      "( ^#{term}$ | #{term} )"
    end.join(' & ')
  end
end
