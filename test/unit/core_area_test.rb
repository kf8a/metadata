require File.expand_path('../../test_helper',__FILE__) 

class CoreAreaTest < ActiveSupport::TestCase
  should have_many :datatables
end
