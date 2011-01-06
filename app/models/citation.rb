class Citation < ActiveRecord::Base
  include ActiveRecord::Transitions

  has_many :authors, :order => :seniority
  belongs_to :citation_type
  belongs_to :website

  accepts_nested_attributes_for :authors
  
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
end
