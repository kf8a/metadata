# Represents a page for non structured data
class Page < ActiveRecord::Base
  has_many :page_images

  accepts_nested_attributes_for :page_images
end

# == Schema Information
#
# Table name: pages
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  body       :text
#  url        :string(255)
#  created_at :datetime
#  updated_at :datetime
#
