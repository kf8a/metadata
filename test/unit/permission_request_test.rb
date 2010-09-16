require 'test_helper'

class PermissionRequestTest < ActiveSupport::TestCase

  should belong_to :user
  should belong_to :datatable

  #TODO figure out why it fails with these
  should validate_presence_of :user
  should validate_presence_of :datatable
end
