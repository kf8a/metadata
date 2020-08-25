# frozen_string_literal: true

# an embedded image in a page
class PageImage < ApplicationRecord
  belongs_to :page

  has_one_attached :image
end
