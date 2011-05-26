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
  
  context 'an author with a double last name' do
    setup do 
      @author = Factory :author, :sur_name => 'Al Fazier', :given_name => 'John'
    end

    should 'have the right name' do
      assert_equal 'Al Fazier, John', @author.name
    end

    should 'be formated correctly as default' do
      assert_equal 'Al Fazier, J.', @author.formatted
    end

    should 'be formated correctly as natural' do
      assert_equal 'J. Al Fazier', @author.formatted(:natural)
    end
  end

  context 'parsing an author string' do
    context 'parsing reverse names' do
      should 'parse Jones, Johnathon' do
        author = Author.parse('Jones, Johnathon')
        assert_equal 'Jones', author.sur_name
        #assert_equal 'Johnathon' author.given_name
      end
      should 'parse Al Fazier, John' do
        author = Author.parse('Al Fazier, John')
        assert_equal 'Al Fazier', author.sur_name
        #assert_equal 'John', author.given_name
      end
    end

    context 'parsing forward names' do

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

