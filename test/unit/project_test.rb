require File.expand_path('../../test_helper',__FILE__)

class ProjectTest < ActiveSupport::TestCase
  should have_many :datasets
end


# == Schema Information
#
# Table name: projects
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  abstract   :text
#  created_at :datetime
#  updated_at :datetime
#

