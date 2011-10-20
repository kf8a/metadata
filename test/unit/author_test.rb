require File.expand_path('../../test_helper',__FILE__)

class AuthorTest < ActiveSupport::TestCase

  context 'parsing an author string' do
    setup do
      @author = Author.new
    end
    context 'parsing reverse names' do

      should 'parse Jones, Johnathon' do
        @author.name = 'Jones, Johnathon'
        assert_equal 'Jones', @author.sur_name
        assert_equal 'Johnathon', @author.given_name
      end
      should 'parse Al Fazier, John' do
        @author.name = 'Al Fazier, John'
        assert_equal 'Al Fazier', @author.sur_name
        assert_equal 'John', @author.given_name
      end

      should 'parse McDonalds, R. J.' do
        @author.name = 'McDonalds, R. J.' 
        assert_equal 'McDonalds', @author.sur_name
        assert_equal 'R', @author.given_name
        assert_equal 'J', @author.middle_name
      end

      should 'parse McDondalds, R.J.' do
        @author.name = 'McDonalds, R.J.' 
        assert_equal 'McDonalds', @author.sur_name
        assert_equal 'R', @author.given_name
        assert_equal 'J', @author.middle_name
      end

      should 'parse McDonads, Rob John Paul' do
        @author.name = 'McDonalds, Rob John Paul' 
        assert_equal 'McDonalds', @author.sur_name
        assert_equal 'Rob', @author.given_name
        assert_equal 'John Paul', @author.middle_name
      end
    end

    context 'parsing forward names' do
      should 'parse Jonathon Jones' do
        @author.name = "Jonathon Jones"
        assert_equal 'Jones', @author.sur_name
        assert_equal 'Jonathon', @author.given_name
      end

      should 'parse Marting Luther King, Jr.' do
        @author.name = "Martin Luther King, Jr."
        assert_equal 'King', @author.sur_name
        assert_equal 'Martin', @author.given_name
        assert_equal 'Luther', @author.middle_name
        assert_equal ', Jr.', @author.suffix
      end

      should 'parse R.J. Paulson' do
        @author.name = 'R.J. Paulson'
        assert_equal 'Paulson', @author.sur_name
        assert_equal 'R', @author.given_name
        assert_equal 'J', @author.middle_name
      end

      should 'parse R J S Paulson' do
        @author.name = 'R J S Paulson'
        assert_equal 'Paulson', @author.sur_name
        assert_equal 'R', @author.given_name
        assert_equal 'J S', @author.middle_name
      end

      should 'parse R. J. S. Paulson' do
        @author.name = 'R. J. S. Paulson' 
        assert_equal 'Paulson', @author.sur_name
        assert_equal 'R', @author.given_name
        assert_equal 'J S', @author.middle_name
      end
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

