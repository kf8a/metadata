require File.expand_path('../../test_helper',__FILE__) 

class AuthorTest < ActiveSupport::TestCase

  should belong_to :citation
  should validate_presence_of 'seniority'
end
