require File.expand_path('../../../test_helper',__FILE__) 

class CitationsHelperTest < ActionView::TestCase
 
   context 'a citation with default format' do
    setup do
      @citation = Citation.new
    end
    
    should 'return a string' do
      assert formatted_as_default(@citation).kind_of?(String)
    end
    
    should 'return it in the right format' do
      result = 'Loecke, T. D., and G. P. Robertson. 2008. Soil resource heterogeneity in the form of aggregated litter alters maize productivity. Plant and Soil 325:231-241'
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

   context 'a citation with book format' do
     setup do
       @citation = Citation.new
       @citation.authors << Author.new(:given_name => 'I', :sur_name => 'Shoko',
                                     :seniority => 1)
       @citation.authors << Author.new(:given_name => 'B', :sur_name => 'Chai',
                                      :seniority => 2)
       @citation.title = "Gene-targeted-metagenomics"
       @citation.citation_type = CitationType.find_by_name('book')
       @citation.publication = 'Handbook of Molecular Microbial Ecology'
     end

     should 'return a string' do
      assert formatted_as_book(@citation).kind_of?(String)
     end

     should 'return the right format' do
      result = "SHOKO, I., CHAI, B. Gene-targeted-metagenomics. In: BRUIJN, F. J. D. (ed.) Handbook of Molecular Microbial Ecology. Wiley/Blackwell Press."
      assert_equal result, formatted_as_book(@citation)
     end
   end
end
