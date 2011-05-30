require 'citation_format'
class Author < ActiveRecord::Base
  include CitationFormat

  belongs_to :citation

  validates_presence_of :seniority

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
      author_array = author_array[0].split.collect {|x| x.split('.') }.flatten
      self.given_name = author_array.slice!(0)
      self.sur_name = author_array.slice!(-1)
      self.middle_name = author_array.join(' ')
    else
      #Must be last, first middle
      self.sur_name = author_array.slice!(0)
      author_array = author_array[0].split.collect {|x| x.split('.') }.flatten
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
