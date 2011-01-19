class Citation < ActiveRecord::Base
  include ActiveRecord::Transitions

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

  scope :published_with_authors_by_sur_name_and_pub_year,
          :joins=> 'left join authors on authors.citation_id = citations.id',
          :conditions => "seniority = 1 and state = 'published'",
          :order => 'pub_year desc, authors.sur_name'
  
  scope :submitted_with_authors_by_sur_name_and_pub_year,
          :joins=> 'left join authors on authors.citation_id = citations.id',
          :conditions => "seniority = 1 and state = 'submitted'",
          :order => 'authors.sur_name, pub_year desc'

  scope :forthcoming_with_authors_by_sur_name_and_pub_year,
          :joins=> 'left join authors on authors.citation_id = citations.id',
          :conditions => "seniority = 1 and state = 'forthcomming'",
          :order => 'authors.sur_name, pub_year desc'

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

  def formatted
    case citation_type.try(:name)
    when 'book' then formatted_book
    else formatted_article
    end
  end

  private

  def formatted_article
    volume_and_page = case
      when has_volume? && start_page_number && ending_page_number
        if start_page_number == ending_page_number
          "#{volume}:#{start_page_number}."
        else
          "#{volume}:#{start_page_number}-#{ending_page_number}."
        end
      when has_volume? && start_page_number
        "#{volume}:#{start_page_number}."
      when has_volume?
        "#{volume}."
      else
        ""
      end

    "#{author_string} #{pub_year}. #{title}. #{publication} #{volume_and_page}".rstrip
  end

  def formatted_book
    "#{author_string} #{pub_year}. #{title}. Pages #{start_page_number}-#{ending_page_number} in #{editor_string}, eds. #{publication}. #{publisher}, #{address}.".rstrip
  end

  def author_string
    author_array = []
    if authors.length > 1
      last_author = authors.pop
      author_array = authors.collect {|author| "#{author.formatted}"}
      author_array.push("#{last_author.formatted(:natural)}.")
    elsif authors.length > 0
      author_array = [authors.first.formatted]
    end 
    author_array.to_sentence(:two_words_connector => ', and ')
  end

  def editor_string
    editor_array = editors.collect do |editor|
      "#{editor.formatted(:natural)}"
    end
    editor_array.to_sentence(:two_words_connector => ', and ')
  end

  def has_volume?
    volume && !volume.empty?
  end
end
