require 'bibtex'

class Citation < ActiveRecord::Base
  include Workflow

  workflow_column :state

  versioned :dependent => :tracking

  has_many :authors, :order => :seniority
  has_many :editors, :order => :seniority

  belongs_to :citation_type
  belongs_to :website

  has_and_belongs_to_many :datatables
  has_and_belongs_to_many :treatments

  accepts_nested_attributes_for :authors
  accepts_nested_attributes_for :editors

  if Rails.env.production?
    has_attached_file :pdf,
        :storage => :s3,
        :bucket => 'metadata_production',
        :path => "/citations/pdfs/:id/:style/:basename.:extension",
        :s3_credentials => File.join(Rails.root, 'config', 's3.yml'),
        :s3_permissions => 'authenticated-read'
  else
    has_attached_file :pdf, :url => "/citations/:id/download",
        :path => ":rails_root/assets/citations/:attachment/:id/:style/:basename.:extension"
  end

  define_index do
    indexes title
    indexes abstract
    indexes authors.sur_name, :as => :authors
    has website_id
  end

  attr_protected :pdf_file_name, :pdf_content_type, :pdf_size

  scope :with_authors_by_sur_name_and_pub_year,
      joins(:authors).where(:authors => {:seniority => 1}).
      order('pub_year desc, authors.sur_name')

  scope :published, where(:state => 'published').with_authors_by_sur_name_and_pub_year
  scope :submitted, where(:state => 'submitted').with_authors_by_sur_name_and_pub_year
  scope :forthcoming, where(:state => 'forthcoming').with_authors_by_sur_name_and_pub_year

  workflow do
    state :submitted do
      event :accept, :transitions_to => :forthcoming
      event :publish, :transitions_to => :published
    end
    state :forthcoming do
      event :publish, :transitions_to => :published
    end
    state :published do
      event :accept, :transitions_to => :forthcoming
    end
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

  def Citation.from_ris(ris_text)
    parser = RisParser::RisParser.new
    trans = RisParser::RisParserTransform.new
    parsed_text = trans.apply(parser.parse(ris_text))
    parsed_text.collect do |stanza|
      citation = case stanza[:type]
      when 'JOUR', 'MGZN'
        ArticleCitation.new
      when 'BOOK'
        BookCitation.new
      when 'CHAP'
        ChapterCitation.new
      when 'CONF'
        ConferenceCitation.new
      when 'RPRT'
        ReportCitation.new
      when 'THES'
        ThesisCitation.new
      else
        Citation.new
      end
      citation.title = stanza[:title]
      if stanza[:primary_date]
        if stanza[:primary_date].to_i != 0 #it is just an integer string
          citation.pub_date = Date.new(stanza[:primary_date].to_i)
        else
          citation.pub_date = Date.parse(stanza[:primary_date])
        end
      end
      citation.save
      stanza[:authors].each_with_index do |author_name, index|
        citation.authors.create(:name => author_name, :seniority => index)
      end
      citation
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

  def formatted
    book? ? formatted_book : formatted_article
  end

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
    endnote = "%0 "
    endnote += endnote_type
    endnote += "%T #{title}\n"
    authors.each { |author| endnote += "%A #{author.formatted}\n" }
    editors.each { |editor| endnote += "%E #{editor.formatted}\n" }
    endnote += endnote_publication_data
    endnote += "%V #{volume}\n" if volume.present?
    endnote += "%P #{start_page_number}-#{ending_page_number}\n" if start_page_number
    endnote += "%D #{pub_year}" if pub_year
    endnote += "\n%X #{abstract}" if abstract
    endnote += "\n%R #{doi}" if doi
    endnote += "\n%U #{publisher_url}" if publisher_url
    endnote += "\n%@ #{isbn}" if isbn
    endnote
  end

  def self.select_options
    classes = descendants.map{ |klass| klass.to_s }.sort
    classes.collect { |klass| [klass.gsub(/Citation/,''), klass] }
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

  def formatted_article
    "#{author_and_year}. #{title}. #{publication} #{volume_and_page}".rstrip
  end

  def volume_and_page
    if volume.blank?
      ""
    elsif page_numbers.blank?
      "#{volume}."
    else
      "#{volume}:#{page_numbers}."
    end
  end

  def page_numbers
    if start_page_number.to_i < ending_page_number.to_i
      "#{start_page_number}-#{ending_page_number}"
    else
      "#{start_page_number}"
    end
  end

  def formatted_book
    "#{author_and_year}. #{title}. #{page_numbers_book}#{editor_string}. #{publication}. #{publisher}, #{address}."
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

  def author_and_year
    authors.empty? ? "#{pub_year}" : "#{author_string} #{pub_year}"
  end

  def author_string
    if authors.length > 1
      last_author = authors.pop
      author_array = authors.collect {|author| "#{author.formatted}"}
      author_array.push("#{last_author.formatted(:natural)}.")
    else
      author_array = [authors.first.formatted]
    end
    author_array.to_sentence(:two_words_connector => ', and ')
  end

  def editor_string
    if editors.blank?
      ""
    else
      editor_array = editors.collect { |editor| editor.formatted(:natural) }
      eds = editor_array.to_sentence(:two_words_connector => ', and ')
      " in #{eds}, eds"
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
    current_seniority = 1
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
