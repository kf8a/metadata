require 'test_helper'

class SpecimenImageTest < ActiveSupport::TestCase
  should_belong_to :specimen
  should_have_attached_file :image
  
end
