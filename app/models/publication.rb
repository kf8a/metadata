class Publication < ActiveRecord::Base
  belongs_to :publication_type
  has_many :affiliations
  has_many :people, :through => :affiliations
  has_and_belongs_to_many :treatments
  
  attr_accessible :year, :citation, :publication_type_id, :abstract, :year
  
  validates_presence_of :citation
  validates_numericality_of :year, :on => :create, :message => "is not a number"
  
  def Publication.find_by_word(word)
    word = '%'+word+'%'
    find(:all, :order => 'year desc', 
      :conditions => 
      [%q{((lower(citation) like lower(?)) or (lower(abstract) like lower(?))) and publication_type_id < 6}, word, word ])
  end
end
