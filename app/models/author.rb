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

  def Author.parse(author_string)

    # authors_array, suffix = author_string.split(',')
    # if ['jr.','sr.','i','ii','iii','iv','v','vi'].include?(suffix.downcase.strip)

    # end
    author_array = author_string.split
    new_author = Author.new
    if author_array[0].include?(',')
      #Last name is first: Jones, Jonathon
      new_author.sur_name = author_array.slice!(0).delete(',')
      if author_array[0].include?(',')
        #It must be firstname, suffix: Martin, Jr.'
        new_author.given_name = author_array.slice!(0).delete(',')
        new_author.suffix = author_array.join(' ')
      else
        new_author.given_name = author_array.slice!(0)
        if author_array[-2].to_s.include?(',')
          #It must be middlename, suffix: Luther, Jr.'
          new_author.suffix = author_array.slice!(-1)
          new_author.middle_name = author_array.join(' ').delete(',')
        else
          new_author.middle_name = author_array.join(' ')
        end
      end
    else
      new_author.given_name = author_array.slice!(0)
      if author_array[-2].to_s.include?(',')
        #It must be sur_name, suffix: King, Jr.'
        new_author.sur_name = author_array.slice!(-2).delete(',')
        new_author.suffix = author_array.slice!(-1)
        new_author.middle_name = author_array.join(' ')
      else
        #assumes it is 'Jonathon David Jones'
        new_author.sur_name = author_array.slice!(-1)
        new_author.middle_name = author_array.join(' ')
      end
    end
    new_author
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
