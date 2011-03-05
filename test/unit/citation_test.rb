require File.expand_path('../../test_helper',__FILE__)

class CitationTest < ActiveSupport::TestCase
  should have_many :authors
  should belong_to :website

  should have_attached_file(:pdf)

  context 'Some citations exist at different dates' do
    setup do
      @oldcitation = Factory.create(:citation, :title => 'Old Citation')
      @oldcitation.updated_at = Date.civil(2000, 1, 1)
      @oldcitation.save
      @newcitation = Factory.create(:citation, :title => 'New Citation')
      @newcitation.updated_at = Date.civil(2002, 1, 1)
      @newcitation.save
    end

    should 'give the right ones with Citation.by_date(date)' do
      date = {'year' => '2001', 'month' => '10', 'day' => '21'}
      assert_equal [@newcitation], Citation.by_date(date)
    end
  end

  context 'a citation object with a single author' do
    setup do
      @citation = Factory :citation
      @citation.authors << Author.new(:sur_name => 'Robertson',
                                      :given_name => 'G', :middle_name => 'P',
                                      :seniority => 1)

      @citation.title = 'Long-term ecological research: Re-inventing network science'
      @citation.publication = 'Frontiers in Ecology and the Environment'
      @citation.volume = '6'
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
      result = 'Robertson, G. P. 2008. Long-term ecological research: Re-inventing network science. Frontiers in Ecology and the Environment 6:281.'
      assert_equal result, @citation.formatted
    end
  end

  context 'a citation object with zero authors' do
    setup do
      @citation = Factory :citation
      @citation.authors = []

      @citation.title = 'Long-term ecological research: Re-inventing network science'
      @citation.publication = 'Frontiers in Ecology and the Environment'
      @citation.volume = '6'
      @citation.start_page_number = 281
      @citation.ending_page_number = 281
      @citation.pub_year = 2008
    end

    should 'be valid' do
      assert @citation.valid?
    end

    should 'be formatted starting with the title' do
      result = '2008. Long-term ecological research: Re-inventing network science. Frontiers in Ecology and the Environment 6:281.'
      assert_equal result, @citation.formatted
    end
  end

  context 'a citation object with multiple authors' do
    setup do
      @citation = ArticleCitation.new
      @citation.authors << Author.new( :sur_name => 'Loecke',
                                       :given_name => 'T', :middle_name => 'D',
                                       :seniority => 1)

      @citation.authors << Author.new(:sur_name => 'Robertson',
                                      :given_name => 'G', :middle_name => 'P',
                                      :seniority => 2)

      @citation.title = 'Soil resource heterogeneity in the form of aggregated litter alters maize productivity'
      @citation.publication = 'Plant and Soil'
      @citation.volume = '325'
      @citation.start_page_number = 231
      @citation.ending_page_number = 241
      @citation.pub_year = 2008
      @citation.abstract = 'An abstract of the article.'
      @citation.save
    end

    should 'be formatted as default' do
      result = 'Loecke, T. D., and G. P. Robertson. 2008. Soil resource heterogeneity in the form of aggregated litter alters maize productivity. Plant and Soil 325:231-241.'
      assert_equal result, @citation.formatted
    end

    should 'be exported to endnote' do
      result = "%0 Journal Article
%T Soil resource heterogeneity in the form of aggregated litter alters maize productivity
%A Loecke, T. D.
%A Robertson, G. P.
%J Plant and Soil
%V 325
%@ 231-241
%D 2008
%X An abstract of the article."
    assert_equal result, @citation.as_endnote
    end
  end

  context 'formatting a book citation' do
    setup do
      @citation = BookCitation.new

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
     @citation.save
    end

    should 'be formatted correctly' do
      result = 'Robertson, G. P., and A. S. Grandy. 2006. Soil system management in temperate regions. Pages 27-39 in N. Uphoff, A. S. Ball, and J. Thies, eds. Biological Approaches to Sustainable Soil Systems. CRC Press, Taylor and Francis Group, Boca Raton, Florida, USA.'
      assert_equal result, @citation.formatted
    end

    should 'be exported as endnote' do
      result = "%0 Book Section
%T Soil system management in temperate regions
%A Robertson, G. P.
%A Grandy, A. S.
%E Uphoff, N.
%E Ball, A. S.
%E Thies, J.
%B Biological Approaches to Sustainable Soil Systems
%I CRC Press, Taylor and Francis Group
%C Boca Raton, Florida, USA
%@ 27-39
%D 2006"

      assert_equal result, @citation.as_endnote
    end
  end

  context 'formatting a submitted citation' do
    setup do
      @citation = Citation.new
      @citation.authors << Author.new(:sur_name => 'Kaufman',
                                      :given_name => 'A',
                                      :middle_name => 'S',
                                      :seniority => 1)
      @citation.title = 'Implications of LCA accounting methods in a corn and corn stover to ethanol system'
      @citation.pub_year = 2009
      @citation.volume = ''
      @citation.save
    end

    should 'be formatted correctly' do
      result = 'Kaufman, A. S. 2009. Implications of LCA accounting methods in a corn and corn stover to ethanol system.'
      assert_equal result, @citation.formatted
    end

    should 'be exported to bibtex'

    should 'be exported to endnote' do
      result = "%0 Journal Article
%T Implications of LCA accounting methods in a corn and corn stover to ethanol system
%A Kaufman, A. S.
%D 2009"

    assert_equal result, @citation.as_endnote
    end
  end

  context 'a citation object with no ending page number' do
    setup do
      @citation = ArticleCitation.new
      @citation.authors << Author.new( :sur_name => 'Loecke',
                                       :given_name => 'T', :middle_name => 'D',
                                       :seniority => 1)

      @citation.authors << Author.new(:sur_name => 'Robertson',
                                      :given_name => 'G', :middle_name => 'P',
                                      :seniority => 2)

      @citation.title = 'Soil resource heterogeneity in the form of aggregated litter alters maize productivity'
      @citation.publication = 'Plant and Soil'
      @citation.volume = '325'
      @citation.start_page_number = 231
      @citation.ending_page_number = nil
      @citation.pub_year = 2008
      @citation.abstract = 'An abstract of the article.'
      @citation.save
    end

    should 'be formatted correctly' do
      assert @citation.formatted.end_with?('Plant and Soil 325:231.')
    end

  end

  context 'a citation object with no start page' do
    setup do
      @citation = ArticleCitation.new
      @citation.authors << Author.new( :sur_name => 'Loecke',
                                       :given_name => 'T', :middle_name => 'D',
                                       :seniority => 1)

      @citation.authors << Author.new(:sur_name => 'Robertson',
                                      :given_name => 'G', :middle_name => 'P',
                                      :seniority => 2)

      @citation.title = 'Soil resource heterogeneity in the form of aggregated litter alters maize productivity'
      @citation.publication = 'Plant and Soil'
      @citation.volume = '325'
      @citation.start_page_number = nil
      @citation.ending_page_number = nil
      @citation.pub_year = 2008
      @citation.abstract = 'An abstract of the article.'
      @citation.save
    end

    should 'be formatted correctly' do
      assert @citation.formatted.end_with?('Plant and Soil 325.')
    end

  end

  context 'a citation object with two editors' do
    setup do
      @citation = BookCitation.new
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

      @citation.publication = 'Biological Approaches to Sustainable Soil Systems'
      @citation.publisher = 'CRC Press, Taylor and Francis Group'
      @citation.address = 'Boca Raton, Florida, USA'
      @citation.save
    end

    should 'be formatted correctly' do
      result = "Robertson, G. P., and A. S. Grandy. 2006. Soil system management in temperate regions. Pages 27-39 in N. Uphoff, and A. S. Ball, eds. Biological Approaches to Sustainable Soil Systems. CRC Press, Taylor and Francis Group, Boca Raton, Florida, USA."
      assert_equal result, @citation.formatted
    end

  end
end
