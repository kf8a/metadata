# frozen_string_literal: true

require 'citation_format'

# Represents an author. This should be linked people in a better world
class Author < ApplicationRecord
  # ActiveRecord::Base
  include CitationFormat

  belongs_to :citation

  validates :seniority, presence: true

  def self.to_enw
    all.collect(&:to_enw).join
  end

  def to_enw
    "\n%A #{formatted}"
  end
end
