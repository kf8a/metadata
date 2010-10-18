require File.expand_path('../../test_helper',__FILE__) 

class CollectionTest < ActiveSupport::TestCase

  should belong_to :datatable
  should validate_presence_of :datatable
end
