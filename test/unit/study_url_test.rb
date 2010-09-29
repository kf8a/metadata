require 'test_helper'

class StudyUrlTest < ActiveSupport::TestCase
  should belong_to :study
  should belong_to :website
end
