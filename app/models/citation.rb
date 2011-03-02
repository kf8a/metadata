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

  attr_protected :pdf_file_name, :pdf_content_type, :pdf_size

  scope :published, where(:state => 'published')
  scope :submitted, where(:state => 'submitted')
  scope :forthcoming, where(:state => 'forthcoming')

  state_machine do
    state :submitted
    state :forthcomming
    state :published

    event :accept do
      transitions :to => :forthcomming, :from => [:submitted, :published]
    end
    event :publish do
      transitions :to => :published, :from => [:fothcomming, :submitted]
    end
  end

  def Citation.by_date(date)
    query_date = Date.civil(date['year'].to_i,date['month'].to_i,date['day'].to_i)
    where('updated_at > ?', query_date).all
  end

  def Citation.sort_by_author_and_date
    all.sort do |a,b|
      auth = a.primary_author_sur_name <=> b.primary_author_sur_name
      auth == 0 ? a.pub_date <=> b.pub_date : auth
    end
  end

  def primary_author_sur_name
    self.authors.find_by_seniority(1).try(:sur_name) if authors
  end

  def book?
    citation_type.try(:name) == 'book'
  end

  def formatted
    book? ? formatted_book : formatted_article
  end

  def as_endnote
    endnote = "%0 "
    endnote += book? ? "Book Section\n" : "Journal Article\n"
    endnote += "%T #{title}\n"
    authors.each { |author| endnote += "%A #{author.formatted}\n" }
    editors.each { |editor| endnote += "%E #{editor.formatted}\n" }
    if book?
      endnote += "%B #{publication}\n"
      endnote += "%I #{publisher}\n"
      endnote += "%C #{address}\n"
    else
      endnote += "%J #{publication}\n" unless publication.blank?
    end
    endnote += "%V #{volume}\n" unless volume.blank?
    endnote += "%@ #{page_numbers}\n" unless page_numbers.blank?
    endnote += "%D #{pub_year}" unless pub_year.blank?
    endnote += "\n%X #{abstract}" unless abstract.blank?
    endnote
  end

  private

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
    if start_page_number.blank?
      ""
    elsif !ending_page_number.blank? && start_page_number != ending_page_number
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