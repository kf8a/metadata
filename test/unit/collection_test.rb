require File.dirname(__FILE__) + '/../test_helper'

class CollectionTest < ActiveSupport::TestCase

  should belong_to :datatable
  should validate_presence_of :datatable
end
