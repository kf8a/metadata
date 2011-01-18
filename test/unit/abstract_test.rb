require File.expand_path('../../test_helper',__FILE__) 

class AbstractTest < ActiveSupport::TestCase
  should validate_presence_of :meeting
  should validate_presence_of :abstract
end
