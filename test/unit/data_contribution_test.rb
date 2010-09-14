require File.dirname(__FILE__) + '/../test_helper'

class DataContributionTest < ActiveSupport::TestCase

  should belong_to :person
  should belong_to :datatable
  should belong_to :role
  
  should validate_presence_of :role
  
end
