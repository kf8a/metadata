require File.expand_path('../../test_helper',__FILE__) 

class EditorTest < ActiveSupport::TestCase

  should belong_to :citation
  should validate_presence_of 'seniority'
end





# == Schema Information
#
# Table name: editors
#
#  id          :integer         not null, primary key
#  sur_name    :string(255)
#  given_name  :string(255)
#  middle_name :string(255)
#  seniority   :integer
#  person_id   :integer
#  citation_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#  suffix      :string(255)
#

