# frozen_string_literal: true

# A meeting abstract
class Abstract < ApplicationRecord
  belongs_to :meeting_abstract_type
  belongs_to :meeting

  validates :meeting, presence: true

  self.table_name = 'meeting_abstracts'

  has_one_attached :pdf

  # TODO: update validation for active storage
  # validates_attachment_content_type :pdf, content_type: /pdf/

  def self.by_authors
    order :authors
  end
end
