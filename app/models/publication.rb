class Publication < ActiveRecord::Base
  belongs_to :publication_type
  has_many :affiliations
  has_many :people, :through => :affiliations
  has_and_belongs_to_many :treatments

  attr_accessible :year, :citation, :publication_type_id, :abstract, :year, :treatment_ids

  accepts_nested_attributes_for :treatments

  validates_presence_of :citation
  validates_numericality_of :year, :on => :create, :message => "is not a number"

  def Publication.find_by_word(word)
    word = '%'+word+'%'
    Publication.order('year desc').where(%q{((lower(citation) like lower(?)) or (lower(abstract) like lower(?))) and publication_type_id < 6}, word, word)
  end
end


# == Schema Information
#
# Table name: publications
#
#  id                  :integer         not null, primary key
#  publication_type_id :integer
#  citation            :text
#  abstract            :text
#  year                :integer
#  file_url            :string(255)
#  title               :text
#  authors             :text
#  source_id           :integer
#  parent_id           :integer
#  content_type        :string(255)
#  filename            :string(255)
#  size                :integer
#  width               :integer
#  height              :integer
#

