require 'citation_format'

class Editor < ActiveRecord::Base
  include CitationFormat

  belongs_to :citation

  validates_presence_of :seniority
end

# == Schema Information
#
# Table name: editors
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
#

