require File.dirname(__FILE__) + '/../test_helper'

class OwnershipTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :datatable
  
  should validate_presence_of :user
  should validate_presence_of :datatable
end
