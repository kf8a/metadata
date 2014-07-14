# encoding: utf-8
require 'bibtex'

class Citation < ActiveRecord::Base
  include Workflow

  workflow_column :state

  versioned :dependent => :tracking

  has_many :authors, :order => :seniority, :dependent => :destroy
  has_many :editors, :order => :seniority, :dependent => :destroy

  belongs_to :citation_type
  belongs_to :website

  has_and_belongs_to_many :datatables
  has_and_belongs_to_many :treatments,  conditions: { use_in_citations: true }

  accepts_nested_attributes_for :authors
  accepts_nested_attributes_for :editors

  validates_presence_of :authors

  if Rails.env.production?
    has_attached_file :pdf,
        :storage => :s3,
        :bucket => 'metadata_production',
        :path => "/citations/pdfs/:id/:style/:basename.:extension",
        :s3_credentials => File.join(Rails.root, 'config', 's3.yml'),
        :s3_permissions => 'authenticated-read'
  else
    has_attached_file :pdf, :url => "/citations/:id/download",
        :path => ":rails_root/uploads/citations/:attachment/:id/:style/:basename.:extension"
  end

  # define indexes for thinking_sphinks
  define_index do
    indexes title
    indexes abstract
    indexes authors.sur_name, :as => :authors
    indexes publication
    has website_id
    set_property :enable_star => 1
    set_property :min_infix_len => 1
  end

  # attr_accessible :Tag, :title, :abstract, 
  attr_protected :pdf_file_name, :pdf_content_type, :pdf_size

  # the REAL publications not including reports
  scope :publications, where(%q{type != 'ConferenceCitation'}).where(%q{type != 'ReportCitation'})

  scope :bookish, where(%q{type in ('BookCitation', 'ChapterCitation')})

  scope :with_authors_by_sur_name_and_pub_year,
      joins(:authors).where(:authors => {:seniority => 1}).
      order('pub_year desc, authors.sur_name')

  scope :published,   where(:state => 'published').with_authors_by_sur_name_and_pub_year
  scope :submitted,   where(:state => 'submitted').with_authors_by_sur_name_and_pub_year
  scope :forthcoming, where(:state => 'forthcoming').with_authors_by_sur_name_and_pub_year

  scope :books, where(:type => 'book')

  scope :next, lambda { |p| {:conditions => ["id > ?", p.id], :limit => 1, :order => "id"} }
  scope :previous, lambda { |p| {:conditions => ["id < ?", p.id], :limit => 1, :order => "id desc"} }

  workflow do
    state :submitted do
      event :accept,  :transitions_to => :forthcoming
      event :draft,   :transitions_to => :draft
      event :publish, :transitions_to => :published
    end
    state :draft do
      event :submit,  :transitions_to => :submitted
    end
    state :forthcoming do
      event :publish, :transitions_to => :published
    end
    state :published do
      event :accept,  :transitions_to => :forthcoming
    end
  end

  def Citation.by_treatment(treatment)
    includes(:treatments).where('treatments.id = ?', treatment)
  end

  def Citation.from_website(website_id)
    where(:website_id => website_id)
  end

  def Citation.by_date(date)
    query_date = Date.civil(date['year'].to_i,date['month'].to_i,date['day'].to_i)
    where('updated_at > ?', query_date)
  end


  def Citation.to_enw(array_of_citations)
    array_of_citations.collect { |citation| citation.to_enw }.join("\r\n\r\n")
  end

  def Citation.to_bib(array_of_citations)
    bib = BibTeX::Bibliography.new
    array_of_citations.each {|citation| bib << citation.to_bib}

    bib.to_s
  end

  def Citation.by_type(type)
    where(:type => type)
  end

  def Citation.sorted_by(sorter)
    sorter.downcase!
    #Since primary author and date is default, it is already sorted that way
    unless sorter == "primary author and date(default)"
      order(sorter)
    end
  end

  def Citation.type_from_ris_type(type)
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

  def Citation.from_ris(ris_text, pdf_folder = nil)
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

  def get_attribute_from_ris_stanza(stanza, attribute_name, ris_name=nil)
    ris_name = attribute_name.to_sym unless ris_name
    self.send(attribute_name + "=", stanza[ris_name])
  end

  def get_attributes_from_ris_stanza(stanza, attribute_array)
    attribute_array.each do |attribute_name|
      get_attribute_from_ris_stanza(stanza, attribute_name)
    end
  end

  def Citation.citation_from_ris_stanza(stanza, pdf_folder)
    citation = type_from_ris_type(stanza[:type]).new
    same_name_attributes = ['title',
                            'secondary_title',
                            'series_title',
                            'pub_year',
                            'volume',
                            'abstract',
                            'doi']
    citation.get_attributes_from_ris_stanza(stanza, same_name_attributes)
    citation.get_attribute_from_ris_stanza(stanza, 'publication', :journal)
    citation.date_from_ris_date(stanza[:primary_date]) if stanza[:primary_date]
    citation.page_number_from_ris( stanza[:start_page], stanza[:end_page]) 
    citation.pdf_from_ris_pdf(stanza[:pdf], pdf_folder) if pdf_folder && stanza[:pdf]

    citation.save
    citation.authors_from_ris_authors(stanza[:authors])
    citation
  end


  def date_from_ris_date(ris_date)
    if ris_date.to_i != 0 #it is just an integer string
      self.pub_date = Date.new(ris_date.to_i)
    else
      self.pub_date = Date.parse(ris_date)
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
        p "No such file: #{real_path}"
      end
    end
  end

  def authors_from_ris_authors(ris_authors)
    ris_authors.each_with_index do |author_name, index|
      self.authors.create(:name => author_name, :seniority => index)
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
    token_array.each do |token|
      self.send(name_of_class.tableize) << name_of_class.constantize.find_by_id(author_id)
    end
  end

  def editor_block
    block(editors)
  end

  def editor_block=(string_of_editors = '')
    set_as_block('Editor', string_of_editors)
  end

  def file_title
    "#{self.id}-#{self.title}-#{self.pub_year}"
  end

  def book?
    citation_type.try(:name) == 'book'
  end

  # def formatted(options={})
  #   book? ? formatted_book(options) : formatted_article(options)
  # end

  def to_bib
    entry = BibTeX::Entry.new
    entry.type = bibtex_type.to_s
    entry.key = "citation_#{id}"
    entry << bib_hash

    entry
  end

  def bib_hash
    hash = {
      :abstract   => abstract,
      :author     => authors.collect { |author| author.full_name }.join(' and '),
      :editor     => editors.collect { |editor| editor.full_name }.join(' and '),
      :title      => title,
      :publisher  => publisher,
      :year       => pub_year.to_s,
      :address    => address,
      :note       => notes,
      :journal    => publication,
      :pages      => page_numbers,
      :volume     => volume,
      :number     => issue,
      :series     => series_title,
      :isbn       => isbn}
    hash.delete_if { |key, value| value.blank? }
  end

  def to_enw
    endnote = "%0 #{endnote_type}#{title_to_enw}#{authors.to_enw}#{editors.to_enw}#{endnote_publication_data}"
    endnote += "#{volume_to_enw}#{page_numbers_to_enw}#{pub_year_to_enw}#{abstract_to_enw}#{doi_to_enw}"
    endnote += "#{publisher_url_to_enw}#{isbn_to_enw}"
    endnote += "#{accession_number_to_enw}"
    endnote +=  "\n"
    endnote
  end

  def self.select_options
    classes = descendants.map{ |klass| klass.to_s }.sort
    classes.collect { |klass| [klass.gsub(/Citation/,''), klass] }
  end

  def short_author_string
    if authors.length > 3
      return authors.first.formatted + ', et.al. '
    elsif authors.length > 0
      author_string
    else
      ''
    end
  end

  def formatted(options={})
    "#{author_and_year(options)} #{title_and_punctuation} #{publication} #{volume_and_page}".rstrip
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
      "%B #{publication}\n" + "%I #{publisher}\n" + "%C #{address}\n"
    else
      publication.present? ? "%J #{publication}\n" : ""
    end
  end


  def volume_and_page
    if volume.blank?
      if self.doi.blank?
        ""
      else
        "doi: #{self.doi}"
      end
    elsif page_numbers.blank?
      "#{volume}."
    else
      "#{volume}:#{page_numbers}."
    end
  end

  def volume_to_enw
    volume.present? ? "%V #{volume}\n" : ""
  end

  def accession_number_to_enw
    "\n%M KBS.#{id}"
  end

  def title_and_punctuation
    return '' unless self.title
    self.title.rstrip!
    if (title =~ /[\?\!\.]$/)
      title
    else
      title + '.'
    end
  end

  def page_numbers
    if start_page_number.to_i < ending_page_number.to_i
      "#{start_page_number}-#{ending_page_number}"
    else
      "#{start_page_number}"
    end
  end

  def page_numbers_book
    if page_numbers.blank?
      ""
    elsif page_numbers.include?('-')
      "Pages #{page_numbers}"
    else
      "Page #{page_numbers}"
    end
  end

  def page_numbers_to_enw
    page_numbers.blank? ? "" : "%P #{page_numbers}\n"
  end

  def pub_year_to_enw
    "%D #{pub_year}"
  end

  def abstract_to_enw
    abstract? ? "\n%X #{abstract}" : ""
  end

  def doi_to_enw
    doi? ? "\n%R #{doi}" : ""
  end

  def isbn_to_enw
    isbn? ? "\n%@ #{isbn}" : ""
  end

  def publisher_url_to_enw
    publisher_url? ? "\n%U #{publisher_url}" : ""
  end

  def title_to_enw
    "%T #{title}\n"
  end

  def pub_year_with_punctuation 
    pub_year ?  "#{pub_year}." : ""
  end

  def author_and_year(options={})
    if options[:long]
      authors.empty? ? "#{pub_year_with_punctuation}" : "#{author_string} #{pub_year_with_punctuation}".rstrip
    else
      authors.empty? ? "#{pub_year_with_punctuation}" : "#{short_author_string} #{pub_year_with_punctuation}".rstrip
    end
  end

  # use natural order for second and subsequent authors
  # 
  def author_string
    my_authors = authors.all
    if my_authors.length > 1
      last_author = my_authors.pop
      first_author = my_authors.shift
      author_array = my_authors.collect {|author| "#{author.formatted(:natural)}"}
      author_array.push("#{last_author.formatted(:natural)}.")
      author_array.unshift("#{first_author.formatted}")
    else
      author_array = [authors.first.formatted]
    end
    author_array.to_sentence(:two_words_connector => ', and ')
  end

  def editor_string
   if editors.present? 
      editor_array = editors.collect { |editor| editor.formatted(:natural) }
      eds = editor_array.to_sentence(:two_words_connector => ', and ')
      " in #{eds}, eds. "
    end
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
    self.send(table_name).clear
    current_seniority = 1   #TODO should this be zero based?
    string_of_names.each_line do |name_string|
      if name_string[0].match('\d')
        treat_as_token_list(name_of_class, name_string)
      else
        self.send(table_name) << name_of_class.constantize.create(:name      => name_string,
                                                                  :seniority => current_seniority)
      end

      current_seniority += 1
    end
  end
end





# == Schema Information
#
# Table name: citations
#
#  id                      :integer         not null, primary key
#  title                   :text
#  abstract                :text
#  pub_date                :date
#  pub_year                :integer
#  citation_type_id        :integer
#  address                 :text
#  notes                   :text
#  publication             :string(255)
#  start_page_number       :integer
#  ending_page_number      :integer
#  periodical_full_name    :text
#  periodical_abbreviation :string(255)
#  volume                  :string(255)
#  issue                   :string(255)
#  city                    :string(255)
#  publisher               :string(255)
#  secondary_title         :string(255)
#  series_title            :string(255)
#  isbn                    :string(255)
#  doi                     :string(255)
#  full_text               :text
#  publisher_url           :string(255)
#  website_id              :integer
#  created_at              :datetime
#  updated_at              :datetime
#  pdf_file_name           :string(255)
#  pdf_content_type        :string(255)
#  pdf_file_size           :integer
#  pdf_updated_at          :datetime
#  state                   :string(255)
#  open_access             :boolean         default(FALSE)
#  type                    :string(255)
#
