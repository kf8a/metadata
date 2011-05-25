require 'citation_format'
class Author < ActiveRecord::Base
  include CitationFormat

  belongs_to :citation

  validates_presence_of :seniority

  def name
    if sur_name.present?
      if middle_name.present? || given_name.present?
        sur_text = "#{sur_name},"
      else
        sur_text = sur_name
      end
    else
      sur_text = ''
    end

    given_text  = given_name.present?  ? " #{given_name}"  : ''
    middle_text = middle_name.present? ? " #{middle_name}" : ''
    suffix_text = suffix.present?      ? ", #{suffix}"     : ''

    sur_text + given_text + middle_text + suffix_text
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
