require 'test_helper'

class OwnershipTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :datatable
end
