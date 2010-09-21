require File.dirname(__FILE__) + '/../test_helper'

class SponsorTest < ActiveSupport::TestCase
  should have_db_column :data_restricted
  
  should have_many :memberships
end
