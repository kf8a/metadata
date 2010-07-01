require 'test_helper'

class PermissionTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :datatable
  should belong_to :owner
end
