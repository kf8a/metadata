# an embedded image in a page
class PageImage < ApplicationRecord
  belongs_to :page

  has_attached_file :image
end
