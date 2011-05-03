require 'bibtex'

class Citation < ActiveRecord::Base
  include ActiveRecord::Transitions

  versioned :dependent => :tracking

  has_many :authors, :order => :seniority
  has_many :editors, :order => :seniority

  belongs_to :citation_type
  belongs_to :website

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

  state_machine do
    state :submitted
    state :forthcoming
    state :published

    event :accept do
      transitions :to => :forthcoming, :from => [:submitted, :published]
    end
    event :publish do
      transitions :to => :published, :from => [:forthcoming, :submitted]
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

  def Citation.sorted_by(sorter)
    #Since primary author and date is default, it is already sorted that way
    unless sorter.downcase == "primary author and date(default)"
      order(sorter.downcase)
    end
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
    entry.type = bibtex_type
    entry.key = "citation_#{id}"
    entry[:abstract] = abstract if abstract.present?
    entry[:author] = authors.collect { |author| "#{author.given_name} #{author.middle_name} #{author.sur_name}"}.join(' and ')
    entry[:editor] = editors.collect { |editor| "#{editor.given_name} #{editor.middle_name} #{editor.sur_name}"}.join(' and ')
    entry[:title] = title if title.present?
    entry[:publisher] = publisher if publisher.present?
    entry[:year] = pub_year.to_s if pub_year.present?
    entry[:address] = address if address.present?
    entry[:note] = notes if notes.present?
    entry[:journal] = publication if publication.present?
    entry[:pages] = page_numbers if page_numbers.present?
    entry[:volume] = volume if volume.present?
    entry[:number] = issue if issue.present?
    entry[:series] = series_title if series_title.present?
    entry[:isbn] = isbn if isbn.present?

    entry
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
#  type                    :string(255)
#  open_access             :boolean         default(FALSE)
#
