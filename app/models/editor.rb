require 'citation_format'

class Editor < ActiveRecord::Base
  include CitationFormat

  belongs_to :citation

  validates_presence_of :seniority

  def Editor.to_enw
    all.collect { |editor| editor.to_enw }.join
  end

  def to_enw
    "\n%E #{formatted}"
  end
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
#  suffix      :string(255)
#
