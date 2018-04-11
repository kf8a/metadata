# Represents a page for non structured data
class Page < ApplicationRecord
  has_many :page_images

  accepts_nested_attributes_for :page_images
end
