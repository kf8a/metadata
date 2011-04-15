require File.expand_path('../../test_helper',__FILE__) 

class AbstractTest < ActiveSupport::TestCase
  should validate_presence_of :meeting
  should validate_presence_of :abstract
end

# == Schema Information
#
# Table name: meeting_abstracts
#
#  id         :integer         not null, primary key
#  title      :text
#  authors    :text
#  abstract   :text
#  meeting_id :integer
#

