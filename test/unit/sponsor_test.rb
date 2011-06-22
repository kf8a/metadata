require File.expand_path('../../test_helper',__FILE__) 

class SponsorTest < ActiveSupport::TestCase
  should have_db_column :data_restricted
  
  should have_many :memberships
end





# == Schema Information
#
# Table name: sponsors
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  data_restricted    :boolean         default(FALSE)
#  data_use_statement :text
#

