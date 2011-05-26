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
    suffix_text = suffix.present?      ? suffix            : '' #proper suffix should already be in ', Jr.' form

    sur_text + given_text + middle_text + suffix_text
  end

  def name=(author_string='')
    list_of_suffices = ['esq','esquire','jr','sr','2','i','ii','iii','iv','v','clu','chfc','cfp','md','phd']
    author_array = author_string.split(',')
    #Get suffices
    suffix_text = ''
    while author_array[-1].present? && list_of_suffices.include?(author_array[-1].downcase.delete('.').strip)
      suffix_text = ', ' + author_array.slice!(-1).strip + suffix_text
    end
    self.suffix = suffix_text
    if author_array.count == 1
      #Must be first middle last
      author_array = author_array[0].split
      self.given_name = author_array.slice!(0)
      self.sur_name = author_array.slice!(-1)
      self.middle_name = author_array.join(' ')
    else
      #Must be last, first middle
      self.sur_name = author_array.slice!(0)
      author_array = author_array[0].split
      self.given_name = author_array.slice!(0)
      self.middle_name = author_array.join(' ')
    end
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
