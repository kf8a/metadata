require 'citation_format'
class Author < ActiveRecord::Base
  include CitationFormat

  belongs_to :citation

  validates_presence_of :seniority

  def name
    ab = ''
    ab += self.given_name if self.given_name.present?
    if self.middle_name.present?
      ab += " #{self.middle_name} "
    end
    ab += self.sur_name if self.sur_name.present?
    if self.suffix.present?
      ab += ", #{self.suffix}"
    end

    ab
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
