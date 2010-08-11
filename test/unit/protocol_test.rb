require File.dirname(__FILE__) + '/../test_helper'

class ProtocolTest < ActiveSupport::TestCase
  should have_and_belong_to_many :websites
  should have_and_belong_to_many :datatables
end
