require 'test_helper'

class CitationsHelperTest < ActionView::TestCase
 
   context 'a citation' do
    setup do
      @citation = Citation.new
    end
    
    should 'return a string' do
      assert formatted_as_default(@citation).kind_of?(String)
    end
    
    context 'with one author' do
      setup do
        @sur_name    = 'Blacke'
        @given_name  = 'Walter'
        author = Factory :author
        author.sur_name = @sur_name
        author.given_name = @given_name
        @citation.authors << author
      end
      
      should 'return the name in the citation' do
        assert formatted_as_default(@citation) == "#{@sur_name} #{@given_name}. . <em></em>  "
      end
      
      context 'and a volume' do
        setup do
          @volume = '5'
          @citation.volume = @volume
        end
        
        should 'return the volume number as well' do
          assert formatted_as_default(@citation) == "#{@sur_name} #{@given_name}. . <em></em>  #{@volume}"
        end
      end
    end
  end
end
