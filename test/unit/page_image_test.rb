require File.expand_path('../../test_helper',__FILE__) 

class PageImageTest < ActiveSupport::TestCase
 
  should belong_to :page
  
  should have_attached_file(:image)
end

# == Schema Information
#
# Table name: page_images
#
#  id                 :integer         not null, primary key
#  title              :string(255)
#  attribution        :string(255)
#  page_id            :integer
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#

