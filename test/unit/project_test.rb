require File.expand_path('../../test_helper',__FILE__)

class ProjectTest < ActiveSupport::TestCase
  should have_many :datasets
end