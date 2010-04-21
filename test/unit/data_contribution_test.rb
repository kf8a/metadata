require 'test_helper'

class DataContributionTest < ActiveSupport::TestCase

  should_belong_to :person
  should_belong_to :datatable
  should_belong_to :role
end
