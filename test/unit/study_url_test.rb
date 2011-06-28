require 'test_helper'

class StudyUrlTest < ActiveSupport::TestCase
  should belong_to :study
  should belong_to :website
end





# == Schema Information
#
# Table name: study_urls
#
#  id         :integer         not null, primary key
#  website_id :integer
#  study_id   :integer
#  url        :string(255)
#

