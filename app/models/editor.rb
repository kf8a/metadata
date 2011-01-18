require 'citation_format'

class Editor < ActiveRecord::Base
  include CitationFormat

  belongs_to :citation

  validates_presence_of :seniority
end
