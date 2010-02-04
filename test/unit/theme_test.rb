require File.dirname(__FILE__) + '/../test_helper'

class ThemeTest < ActiveSupport::TestCase
  should_have_and_belong_to_many :datasets
  should_have_many :datatables
end
