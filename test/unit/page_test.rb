require File.expand_path('../../test_helper',__FILE__) 

class PageTest < ActiveSupport::TestCase
  should have_many :page_images
  should_accept_nested_attributes_for :page_images
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

