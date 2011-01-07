class Citation < ActiveRecord::Base
  include ActiveRecord::Transitions

  has_many :authors, :order => :seniority
  has_many :editors, :order => :seniority

  belongs_to :citation_type
  belongs_to :website

  accepts_nested_attributes_for :authors
  accepts_nested_attributes_for :editors
  
  has_attached_file :pdf, :url => "/assets/citations/:attachment/:id/:style/:basename.:extension",  
   :path => ":rails_root/assets/citations/:attachment/:id/:style/:basename.:extension"
  
  attr_protected :pdf_file_name, :pdf_content_type, :pdf_size

  scope :published_with_authors_by_sur_name_and_pub_year,
          :joins=> 'left join authors on authors.citation_id = citations.id',
          :conditions => "seniority = 1 and state = 'published'",
          :order => 'authors.sur_name, pub_year desc'
  
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
    volume_and_page = case
      when volume && start_page_number && ending_page_number
        if start_page_number == ending_page_number
          "#{volume}:#{start_page_number}"
        else
          "#{volume}:#{start_page_number}-#{ending_page_number}"
        end
      when volume && start_page_number
        "#{volume}:#{start_page_number}"
      when volume
        "#{volume}"
      else
        ""
      end
    
    "#{author_string} #{pub_year}. #{title}. #{publication} #{volume_and_page}"
  end

  private

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
end
