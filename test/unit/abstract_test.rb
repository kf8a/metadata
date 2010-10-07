require 'test_helper'

class AbstractTest < ActiveSupport::TestCase
  should validate_presence_of :meeting
  should validate_presence_of :abstract
end
