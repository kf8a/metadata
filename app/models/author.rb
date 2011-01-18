require 'citation_format'
class Author < ActiveRecord::Base
  include CitationFormat
  
  belongs_to :citation
  
  validates_presence_of :seniority

end
