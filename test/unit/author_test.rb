require File.dirname(__FILE__) + '/../test_helper'

class AuthorTest < ActiveSupport::TestCase

  should belong_to :citation
  should validate_presence_of 'seniority'
end
