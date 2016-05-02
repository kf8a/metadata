require 'citation_format'

class Author < ActiveRecord::Base
  include CitationFormat

  belongs_to :citation

  validates_presence_of :seniority

  def Author.to_enw
    all.collect { |author| author.to_enw }.join
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
