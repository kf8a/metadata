require 'citation_format'

# Represents an author. This should be linked people in a better world
class Author < ActiveRecord::Base
  include CitationFormat

  belongs_to :citation

  validates :seniority, presence: true

  def self.to_enw
    all.collect(&:to_enw).join
  end

  def to_enw
    "\n%A #{formatted}"
  end
end

# == Schema Information
#
# Table name: authors
#
#  id          :integer         not null, primary key
#  sur_name    :string(255)
#  given_name  :string(255)
#  middle_name :string(255)
#  seniority   :integer
#  person_id   :integer
#  citation_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#  suffix      :string(255)
#
