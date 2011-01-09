require File.expand_path('../../test_helper',__FILE__) 

class CitationTest < ActiveSupport::TestCase
  should belong_to :citation_type
  should have_many :authors
  should belong_to :website
  
  should have_attached_file(:pdf)

  context 'a citation object with a single author' do
    setup do
      @citation = Factory :citation
      @citation.authors << Author.new(:sur_name => 'Robertson',
                                      :given_name => 'G', :middle_name => 'P',
                                      :seniority => 1)

      @citation.title = 'Long-term ecological research: Re-inventing network science'
      @citation.publication = 'Frontiers in Ecology and the Environment'
      @citation.volume = 6
      @citation.start_page_number = 281
      @citation.ending_page_number = 281
      @citation.pub_year = 2008
    end
    
    should 'be valid' do
      assert @citation.valid?
    end

    should 'start out as submitted' do
      assert_equal 'submitted', @citation.state
    end

    should 'be formatted as default' do
      result = 'Robertson, G. P. 2008. Long-term ecological research: Re-inventing network science. Frontiers in Ecology and the Environment 6:281'
      assert_equal result, @citation.formatted
    end
  end

  context 'a citation object with multiple authors' do
    setup do
      @citation = Factory :citation
      @citation.authors << Author.new( :sur_name => 'Loecke', 
                                       :given_name => 'T', :middle_name => 'D',
                                       :seniority => 1)

      @citation.authors << Author.new(:sur_name => 'Robertson',
                                      :given_name => 'G', :middle_name => 'P',
                                      :seniority => 2)
      @citation.citation_type = Factory :citation_type, :name => 'article'

      @citation.title = 'Soil resource heterogeneity in the form of aggregated litter alters maize productivity'
      @citation.publication = 'Plant and Soil'
      @citation.volume = 325
      @citation.start_page_number = 231
      @citation.ending_page_number = 241
      @citation.pub_year = 2008
    end
    
    should 'be formatted as default' do
      result = 'Loecke, T. D., and G. P. Robertson. 2008. Soil resource heterogeneity in the form of aggregated litter alters maize productivity. Plant and Soil 325:231-241'
      assert_equal result, @citation.formatted
    end
  end

  context 'formatting a book citation' do
    setup do
      @citation = Factory :citation
      @citation.citation_type = Factory :citation_type, :name => 'book'
      @citation.authors << Author.new(:sur_name => 'Robertson',
                                      :given_name => 'G', :middle_name => 'P',
                                      :seniority => 1)

      @citation.authors << Author.new(:sur_name => 'Grandy',
                                      :given_name => 'A', :middle_name => 'S',
                                      :seniority => 2)
      @citation.pub_year = 2006
      @citation.title    = 'Soil system management in temperate regions'
      @citation.start_page_number = 27
      @citation.ending_page_number = 39
      @citation.editors << Editor.new(:sur_name => 'Uphoff',
                                     :given_name => 'N',
                                     :seniority => 1)
     @citation.editors << Editor.new(:sur_name => 'Ball',
                                     :given_name => 'A',
                                     :middle_name => 'S',
                                     :seniority => 2) 
     @citation.editors << Editor.new(:sur_name => 'Thies',
                                     :given_name => 'J',
                                     :seniority => 3)

     @citation.publication = 'Biological Approaches to Sustainable Soil Systems'
     @citation.publisher = 'CRC Press, Taylor and Francis Group'
     @citation.address = 'Boca Raton, Florida, USA'
    end

    should 'be formatted correctly' do
      result = 'Robertson, G. P., and A. S. Grandy. 2006. Soil system management in temperate regions. Pages 27-39 in N. Uphoff, A. S. Ball, and J. Thies, eds. Biological Approaches to Sustainable Soil Systems. CRC Press, Taylor and Francis Group, Boca Raton, Florida, USA'
      assert_equal result, @citation.formatted
    end
  end
end
