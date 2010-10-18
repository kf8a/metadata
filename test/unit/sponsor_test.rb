require File.expand_path('../../test_helper',__FILE__) 

class SponsorTest < ActiveSupport::TestCase
  should have_db_column :data_restricted
  
  should have_many :memberships
end
