require File.expand_path('../../test_helper',__FILE__) 

class EventTest < ActiveSupport::TestCase
end



# == Schema Information
#
# Table name: events
#
#  id          :integer         not null, primary key
#  title       :string(255)
#  start       :datetime
#  end         :datetime
#  caption     :text
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

