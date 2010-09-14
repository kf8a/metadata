class PageImage < ActiveRecord::Base
  belongs_to :page
  
  has_attached_file :image
end
