require File.expand_path('../../test_helper',__FILE__) 

class DataContributionTest < ActiveSupport::TestCase

  should belong_to :person
  should belong_to :datatable
  should belong_to :role
  
  should validate_presence_of :role
  
end



# == Schema Information
#
# Table name: data_contributions
#
#  id           :integer         not null, primary key
#  person_id    :integer
#  datatable_id :integer
#  role_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#

