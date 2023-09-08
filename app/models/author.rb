# frozen_string_literal: true

require 'citation_format'

# Represents an author. This should be linked people in a better world
class Author < ApplicationRecord
  include CitationFormat

  belongs_to :citation, optional: true

  validates :seniority, presence: true

  def self.to_enw
    all.collect(&:to_enw).join
  end

  def to_enw
    "\n%A #{formatted}"
  end

  def ld_json
    { "@type": "Person",
      "name": name,
    }
  end
end
