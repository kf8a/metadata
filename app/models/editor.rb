# frozen_string_literal: true

require 'citation_format'

# a person that has edited a book or article
class Editor < ApplicationRecord
  include CitationFormat

  belongs_to :citation, optional: true

  validates :seniority, presence: true

  def self.to_enw
    all.collect(&:to_enw).join
  end

  def to_enw
    "\n%E #{formatted}"
  end
end
