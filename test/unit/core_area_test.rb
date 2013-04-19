require File.expand_path('../../test_helper',__FILE__) 

class CoreAreaTest < ActiveSupport::TestCase
  should have_and_belong_to_many :datatables
end





# == Schema Information
#
# Table name: core_areas
#
#  id   :integer         not null, primary key
#  name :string(255)
#

