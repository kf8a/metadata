# frozen_string_literal: true

require 'bibtex'

# Reference for a publication of some sort
class Citation < ApplicationRecord
  include WorkflowActiverecord

  workflow_column :state

  # versioned dependent: :tracking

  has_many :authors, -> { order(:seniority) }, dependent: :destroy, inverse_of: :citation
  has_many :editors, -> { order(:seniority) }, dependent: :destroy, inverse_of: :citation

  belongs_to :citation_type, optional: true
  belongs_to :website, optional: true

  has_and_belongs_to_many :datatables, optional: true
  has_and_belongs_to_many :treatments, conditions: { use_in_citations: true }, optional: true

  accepts_nested_attributes_for :authors
  accepts_nested_attributes_for :editors

  validates :authors, presence: true

  #TODO: update for active record
  # after_commit :check_for_open_access_paper

  has_one_attached :pdf

  # has_attached_file :pdf,
  #                   storage: :s3,
  #                   bucket: 'metadata-production',
  #                   path: '/citations/pdfs/:id/:style/:basename.:extension',
  #                   s3_credentials: Rails.root.join('config', 's3.yml'),
  #                   s3_region: 'us-east-1',
  #                   s3_permissions: 'authenticated-read'
  # #                 s3_headers: { 'Content-Disposition': 'attachment' }

  # TODO: update validations for active storage
  # validates_attachment_content_type :pdf, content_type: /pdf/

  # the REAL publications not including reports
  scope :publications, lambda {
    where("type != 'ConferenceCitation'")
      .where("type != 'BulletinCitation'")
      .where("type != 'DataCitation'")
  }

  scope :data_citations, -> { where("type = 'DataCitation'") }

  scope :bookish, -> { where("type in ('BookCitation', 'ChapterCitation')") }

  scope :with_authors_by_sur_name_and_pub_year, lambda {
    joins(:authors).where(authors: { seniority: 1 })
                   .order('pub_year desc, authors.sur_name')
  }

  scope :published,   -> { where(state: 'published').with_authors_by_sur_name_and_pub_year }
  scope :submitted,   -> { where(state: 'submitted').with_authors_by_sur_name_and_pub_year }
  scope :forthcoming, -> { where(state: 'forthcoming').with_authors_by_sur_name_and_pub_year }

  scope :with_data, -> { where("data_url <> '' ") }

  scope :books, -> { where(type: 'book') }

  scope :next, ->(p) { { conditions: ['id > ?', p.id], limit: 1, order: 'id' } }
  scope :previous, ->(p) { { conditions: ['id < ?', p.id], limit: 1, order: 'id desc' } }

  workflow do
    state :submitted do
      event :accept,  transitions_to: :forthcoming
      event :draft,   transitions_to: :draft
      event :publish, transitions_to: :published
    end
    state :draft do
      event :submit,  transitions_to: :submitted
    end
    state :forthcoming do
      event :publish, transitions_to: :published
    end
    state :published do
      event :accept,  transitions_to: :forthcoming
    end
  end

  def self.by_treatment(treatment)
    includes(:treatments).references(:treatments).where('treatments.id = ?', treatment)
  end

  def self.from_website(website_id)
    where(website_id: website_id)
  end

  def self.by_date(date)
    query_date = Date.civil(date['year'].to_i, date['month'].to_i, date['day'].to_i)
    where('updated_at > ?', query_date)
  end

  def self.to_enw(array_of_citations)
    array_of_citations.collect(&:to_enw).join("\n") + "\n"
  end

  def self.to_bib(array_of_citations)
    bib = BibTeX::Bibliography.new
    array_of_citations.each { |citation| bib << citation.to_bib }

    bib.to_s
  end

  def self.by_type(type)
    where(type: type)
  end

  def self.sorted_by(sorter)
    sorter.downcase!
    # Since primary author and date is default, it is already sorted that way
    return if sorter == 'primary author and date(default)'

    order(sorter)
  end

  def self.type_from_ris_type(type)
    case type
    when 'JOUR', 'MGZN'
      ArticleCitation
    when 'BOOK'
      BookCitation
    when 'CHAP'
      ChapterCitation
    when 'CONF'
      ConferenceCitation
    when 'RPRT'
      ReportCitation
    when 'THES'
      ThesisCitation
    else
      Citation
    end
  end

  def self.from_ris(ris_text, pdf_folder = nil)
    parser = RisParser::RisParser.new
    trans = RisParser::RisParserTransform.new
    parsed_text = trans.apply(parser.parse(ris_text))
    parsed_text.collect do |stanza|
      logger.info stanza
      citation_from_ris_stanza(stanza, pdf_folder)
    end
  end

  # don't even try to parse the page number
  def page_number_from_ris(start_page, end_page)
    self.start_page_number = start_page
    self.ending_page_number = end_page
  end

  def get_attribute_from_ris_stanza(stanza, attribute_name, ris_name = nil)
    ris_name = attribute_name.to_sym unless ris_name
    send(attribute_name + '=', stanza[ris_name])
  end

  def get_attributes_from_ris_stanza(stanza, attribute_array)
    attribute_array.each do |attribute_name|
      get_attribute_from_ris_stanza(stanza, attribute_name)
    end
  end

  def self.citation_from_ris_stanza(stanza, pdf_folder)
    citation = type_from_ris_type(stanza[:type]).new
    same_name_attributes = %w[title secondary_title series_title pub_year volume abstract doi]
    citation.get_attributes_from_ris_stanza(stanza, same_name_attributes)
    citation.get_attribute_from_ris_stanza(stanza, 'publication', :journal)
    citation.date_from_ris_date(stanza[:primary_date]) if stanza[:primary_date]
    citation.page_number_from_ris(stanza[:start_page], stanza[:end_page])
    citation.pdf_from_ris_pdf(stanza[:pdf], pdf_folder) if pdf_folder && stanza[:pdf]

    citation.save
    citation.authors_from_ris_authors(stanza[:authors])
    citation
  end

  def date_from_ris_date(ris_date)
    self.pub_date = if ris_date.to_i != 0 # it is just an integer string
                      Date.new(ris_date.to_i)
                    else
                      Date.parse(ris_date)
                    end
  end

  def pdf_from_ris_pdf(ris_pdf, pdf_folder)
    ris_pdf.each_line do |line|
      not_internal_path = line.sub('internal-pdf://', '')
      not_internal_path.strip!
      real_path = Rails.root.to_s + '/' + pdf_folder + '/' + not_internal_path
      if File.exist?(real_path)
        self.pdf = File.open(real_path)
      else
        logger.info "No such file: #{real_path}"
      end
    end
  end

  def authors_from_ris_authors(ris_authors)
    ris_authors.each_with_index do |author_name, index|
      authors.create(name: author_name, seniority: index)
    end
  end

  def author_block
    block(authors)
  end

  def author_block=(string_of_authors = '')
    set_as_block('Author', string_of_authors)
  end

  def treat_as_token_list(name_of_class, token_string)
    token_array = token_string.split(',')
    token_array.each do
      send(name_of_class.tableize) << name_of_class.constantize.find_by(id: author_id)
    end
  end

  def editor_block
    block(editors)
  end

  def editor_block=(string_of_editors = '')
    set_as_block('Editor', string_of_editors)
  end

  def file_title
    "#{id}-#{title}-#{pub_year}"
  end

  def book?
    citation_type.try(:name) == 'book'
  end

  def formatted(options = {})
    "#{author_and_year(options)} #{title_and_punctuation} #{publication} #{volume_and_page}".rstrip
  end

  def to_bib
    entry = BibTeX::Entry.new
    entry.type = bibtex_type.to_s
    entry.key = "citation_#{id}"
    entry << bib_hash

    entry
  end

  def bib_hash
    hash = {  abstract: abstract,
              author: authors.collect(&:full_name).join(' and '),
              editor: editors.collect(&:full_name).join(' and '),
              title: title,
              publisher: publisher,
              year: pub_year.to_s,
              address: address,
              note: notes,
              journal: publication,
              pages: page_numbers,
              volume: volume,
              number: issue,
              series: series_title,
              doi: doi,
              isbn: isbn }
    hash.delete_if { |_, value| value.blank? }
  end

  def to_enw
    "%0 #{endnote_type}#{title_to_enw}#{authors.to_enw}"\
    "#{editors.to_enw}#{endnote_publication_data}"\
    "#{volume_to_enw}#{page_numbers_to_enw}#{pub_year_to_enw}"\
    "#{abstract_to_enw}#{doi_to_enw}"\
    "#{publisher_to_enw}#{publisher_url_to_enw}#{isbn_to_enw}#{city_to_enw}"\
    "#{accession_number_to_enw}\n"
  end

  def self.select_options
    classes = descendants.map(&:to_s).sort
    classes.collect { |klass| [klass.gsub(/Citation/, ''), klass] }
  end

  def short_author_string
    return authors.first.formatted + ', et.al. ' if authors.length > 3

    if authors.empty?
      author_string
    else
      authors.first.formatted + ' and ' + authors.last.formatted(:natural) + '.'
    end
  end

  def make_pdf_public
    # pdf.s3_object.acl = :public_read
    pdf.s3_object.acl.put(acl: 'public-read')
  end

  def make_pdf_private
    # pdf.s3_object.acl = :authenticated_read
    pdf.s3_object.acl.put(acl: 'authenticated-read')
  end

  private

  def bibtex_type
    :misc
  end

  def endnote_type
    book? ? "Book Section\n" : "Journal Article\n"
  end

  def endnote_publication_data
    if book?
      "\n%B #{publication}" + "\n%I #{publisher}" + "\n%C #{address}"
    else
      publication.present? ? "\n%J #{publication}" : ''
    end
  end

  def volume_and_page
    if volume.blank?
      doi_citation_part(doi)
    elsif page_numbers.blank?
      "#{volume}."
    else
      "#{volume}:#{page_numbers}."
    end
  end

  def doi_citation_part(doi)
    if doi.blank?
      ''
    else
      "doi: #{doi}"
    end
  end

  def volume_to_enw
    volume.present? ? "\n%V #{volume}" : ''
  end

  def accession_number_to_enw
    "\n%M KBS.#{id}"
  end

  def title_and_punctuation
    return '' if title.blank?

    title.rstrip!
    if title.match?(/[\?\!\.]$/)
      title
    else
      title + '.'
    end
  end

  def page_numbers
    if start_page_number.to_i < ending_page_number.to_i
      "#{start_page_number}-#{ending_page_number}"
    else
      start_page_number.to_s
    end
  end

  def page_numbers_book
    if page_numbers.blank?
      ''
    elsif page_numbers.include?('-')
      "Pages #{page_numbers}"
    else
      "Page #{page_numbers}"
    end
  end

  def page_numbers_to_enw
    page_numbers.blank? ? '' : "\n%P #{page_numbers}"
  end

  def pub_year_to_enw
    pub_year? ? "\n%D #{pub_year}" : ''
  end

  # add Abstract first removing any line endings
  def abstract_to_enw
    abstract? ? "\n%X #{abstract.delete("\n").delete("\r")}" : ''
  end

  def doi_to_enw
    doi? ? "\n%R #{doi}" : ''
  end

  def isbn_to_enw
    isbn? ? "\n%@ #{isbn}" : ''
  end

  def publisher_to_enw
    publisher? ? "\n%I #{publisher}" : ''
  end

  def publisher_url_to_enw
    publisher_url? ? "\n%U #{publisher_url}" : ''
  end

  def city_to_enw
    city? ? "\n%C #{city}" : ''
  end

  def title_to_enw
    "%T #{title}"
  end

  def pub_year_with_punctuation
    pub_year ?  "#{pub_year}." : ''
  end

  def author_and_year(options = {})
    return pub_year_with_punctuation.to_s if authors.empty?

    if options[:long]
      author_and_pub_year_string(author_string)
    else
      author_and_pub_year_string(short_author_string)
    end
  end

  def author_and_pub_year_string(author_string)
    "#{author_string} #{pub_year_with_punctuation}".rstrip
  end

  # use natural order for second and subsequent authors
  def author_string
    my_authors = authors.to_a
    if my_authors.length > 1
      last_author = my_authors.pop
      first_author = my_authors.shift
      author_array = my_authors.collect { |author| author.formatted(:natural).to_s }
      author_array.push("#{last_author.formatted(:natural)}.")
      author_array.unshift(first_author.formatted.to_s)
    else
      author_array = [authors.first.formatted]
    end
    author_array.to_sentence
  end

  def editor_string
    return if editors.blank?

    editor_array = editors.collect { |editor| editor.formatted(:natural) }
    eds = editor_array.to_sentence(two_words_connector: ', and ')
    " in #{eds}, eds. "
  end

  def block(collection)
    ab = ''
    new_line_necessary = false
    collection.order(:seniority).each do |member|
      ab += "\n" if new_line_necessary
      ab += member.name
      new_line_necessary = true
    end

    ab
  end

  def set_as_block(name_of_class, string_of_names = '')
    table_name = name_of_class.tableize
    send(table_name).clear
    current_seniority = 1 # TODO: should this be zero based?
    string_of_names.each_line do |name_string|
      if name_string[0].match(/\d/)
        treat_as_token_list(name_of_class, name_string)
      else
        send(table_name) << name_of_class.constantize.create(name: name_string,
                                                             seniority: current_seniority)
      end

      current_seniority += 1
    end
  end

  protected

  def check_for_open_access_paper
    return unless pdf.attached?

    if open_access
      make_pdf_public
    else
      make_pdf_private
    end
  end
end
