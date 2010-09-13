class Page < ActiveRecord::Base
  has_many :page_images
  
  accepts_nested_attributes_for :page_images
end
