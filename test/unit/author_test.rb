require File.expand_path('../../test_helper',__FILE__) 

class AuthorTest < ActiveSupport::TestCase

  should belong_to :citation
  should validate_presence_of 'seniority'

  context 'an author with a last name' do
    setup do
      @author1 = Factory :author, :sur_name => 'Bond'
      @author2 = Factory :author, :sur_name => 'Bond', :given_name => ''
    end

    should 'be formatted correctly as default' do
      assert_equal 'Bond', @author1.formatted
      assert_equal 'Bond', @author2.formatted
    end

    should 'be formatted corretly as natural' do
      assert_equal 'Bond', @author1.formatted(:natural)
    end
  end

  context 'an author with a first and last name' do
    setup do
      @author1 = Factory :author, :sur_name => 'Bond', :given_name => 'Bill'
      @author2 = Factory :author, :sur_name => 'Bond', :given_name => 'B.'
    end

    should 'be formatted correctly as default' do
      assert_equal 'Bond, B.', @author1.formatted
      assert_equal 'Bond, B.', @author2.formatted
    end

    should 'be formatted correctly as natural' do
      assert_equal 'B. Bond', @author1.formatted(:natural)
      assert_equal 'B. Bond', @author2.formatted(:natural)
    end
  end

  context 'an author with a middle name' do
    setup do
      @author1 = Factory :author, :sur_name => 'Bond', :given_name => 'Bill', :middle_name => 'karl'
    end

    should 'be formatted correctly as default' do
      assert_equal 'Bond, B. K.', @author1.formatted
    end

    should 'be formatted correctly as natural' do
      assert_equal 'B. K. Bond', @author1.formatted(:natural)
    end
  end
end



# == Schema Information
#
# Table name: authors
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

