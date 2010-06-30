require 'test_helper'

class PermissionsTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :datatable
end
