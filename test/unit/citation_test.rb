require File.expand_path('../../test_helper',__FILE__)
require 'bibtex'

class CitationTest < ActiveSupport::TestCase
  should have_many :authors
  should have_many :editors
  should belong_to :website

  should have_attached_file :pdf
  should respond_to? :open_access

  context 'Some citations exist at different dates' do
    setup do
      @oldcitation = FactoryGirl.create(:citation, :title => 'Old Citation')
      @oldcitation.updated_at = Date.civil(2000, 1, 1)
      @oldcitation.save
      @newcitation = FactoryGirl.create(:citation, :title => 'New Citation')
      @newcitation.updated_at = Date.civil(2002, 1, 1)
      @newcitation.save
    end

    should 'Citation.by_date(date) should only include citations after date' do
      date = {'year' => '2001', 'month' => '10', 'day' => '21'}
      assert_includes Citation.by_date(date), @newcitation
      refute_includes Citation.by_date(date), @oldcitation
    end
  end

  context 'a generic citation with a single author' do
    setup do
      # we are testing the workflow so we need actually create a citation
      @citation = FactoryGirl.create :citation

      @citation.authors = [Author.new(:sur_name => 'Robertson',
                                      :given_name => 'G', :middle_name => 'P',
                                      :seniority => 1)]

      @citation.title = 'Long-term ecological research: Re-inventing network science'
      @citation.publication = 'Frontiers in Ecology and the Environment'
      @citation.volume = '6'
      @citation.type = "ArticleCitation"
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

    should 'have one author' do
      assert_equal 1, @citation.authors.size
    end

    should 'be formatted as default' do
      result = 'Robertson, G. P. 2008. Long-term ecological research: Re-inventing network science. Frontiers in Ecology and the Environment 6:281.'
      assert_equal result, @citation.formatted
    end
  end

  context 'a citation object with out a pub year' do
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
      @citation.abstract = 'An abstract of the article.'
      @citation.save
    end

    should 'be exported to endnote' do
      result = "%0 Journal Article
%T Soil resource heterogeneity in the form of aggregated litter alters maize productivity
%A Loecke, T. D.
%A Robertson, G. P.
%J Plant and Soil
%V 325
%P 231-241
%X An abstract of the article.
%M KBS.#{@citation.id}\n"
    assert_equal result, @citation.to_enw
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
      result = 'Loecke, T. D. and G. P. Robertson. 2008. Soil resource heterogeneity in the form of aggregated litter alters maize productivity. Plant and Soil 325:231-241.'
      assert_equal result, @citation.formatted
    end

    should 'be exported to endnote' do
      result = "%0 Journal Article
%T Soil resource heterogeneity in the form of aggregated litter alters maize productivity
%A Loecke, T. D.
%A Robertson, G. P.
%J Plant and Soil
%V 325
%P 231-241
%D 2008
%X An abstract of the article.
%M KBS.#{@citation.id}\n"
    assert_equal result, @citation.to_enw
    end

    context 'as bibtex' do
      setup do
        @entry = @citation.to_bib
      end

      should 'be a bibtex entry' do
        assert_instance_of BibTeX::Entry, @entry
      end

      should 'have right title' do
        assert_equal 'Soil resource heterogeneity in the form of aggregated litter alters maize productivity', @entry.title
      end

      should 'have right publication year' do
        assert_equal '2008', @entry.year
      end

      should 'have right authors' do
        assert_equal 'T D Loecke and G P Robertson', @entry.author.to_s
      end

      should 'have right abstract' do
        assert_equal 'An abstract of the article.', @entry.abstract
      end

      should 'have right type' do
        assert_equal :article, @entry.type
      end
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
      result = 'Robertson, G. P. and A. S. Grandy. 2006. Soil system management in temperate regions. Pages 27-39 in N. Uphoff, A. S. Ball, and J. Thies, eds. Biological Approaches to Sustainable Soil Systems. CRC Press, Taylor and Francis Group, Boca Raton, Florida, USA'
      assert_equal result, @citation.formatted
    end

    should 'be exported as endnote' do
      result = "%0 Book
%T Soil system management in temperate regions
%A Robertson, G. P.
%A Grandy, A. S.
%E Uphoff, N.
%E Ball, A. S.
%E Thies, J.
%B Biological Approaches to Sustainable Soil Systems
%I CRC Press, Taylor and Francis Group
%C Boca Raton, Florida, USA
%P 27-39
%D 2006
%I CRC Press, Taylor and Francis Group
%M KBS.#{@citation.id}\n"

      assert_equal result, @citation.to_enw
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

    context 'as bibtex' do
      setup do
        @entry = @citation.to_bib
      end

      should 'be a bibtex entry' do
        assert_instance_of BibTeX::Entry, @entry
      end

      should 'have right title' do
        assert_equal 'Implications of LCA accounting methods in a corn and corn stover to ethanol system', @entry.title
      end

      should 'have right publication year' do
        assert_equal '2009', @entry.year
      end

      should 'have right authors' do
        assert_equal 'A S Kaufman', @entry.author
      end

      should 'have right type' do
        assert_equal :misc, @entry.type
      end
    end

    should 'be exported to endnote' do
      result = "%0 Journal Article
%T Implications of LCA accounting methods in a corn and corn stover to ethanol system
%A Kaufman, A. S.
%D 2009
%M KBS.#{@citation.id}\n"

    assert_equal result, @citation.to_enw
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
      result = "Robertson, G. P. and A. S. Grandy. 2006. Soil system management in temperate regions. Pages 27-39 in N. Uphoff, and A. S. Ball, eds. Biological Approaches to Sustainable Soil Systems. CRC Press, Taylor and Francis Group, Boca Raton, Florida, USA"
      assert_equal result, @citation.formatted
    end

    context 'as bibtex' do
      setup do
        @entry = @citation.to_bib
      end

      should 'be a bibtex entry' do
        assert_instance_of BibTeX::Entry, @entry
      end

      should 'have right title' do
        assert_equal 'Soil system management in temperate regions', @entry.title
      end

      should 'have right publication year' do
        assert_equal '2006', @entry.year
      end

      should 'have right authors' do
        assert_equal 'G P Robertson and A S Grandy', @entry.author
      end

      should 'have the right type' do
        assert_equal :book, @entry.type
      end
    end

  end


  context 'a citation with a doi but no volume' do 
    setup do
      @cite = FactoryGirl.build :citation, :doi => 'my_doi_string'
    end

    should 'display the doi in the formatted citation' do
      assert_match /my_doi_string/, @cite.formatted
    end
  end

  context 'a citation with no pub year' do
    setup do
      auth  = FactoryGirl.build :author, :sur_name=>'Babbit', :given_name=>'Bob'
      @cite = FactoryGirl.build :citation, :title => 'A title', :authors => [auth]
    end

    should 'not have a dot after the pub year' do
      assert_equal 'Babbit, B. A title.', @cite.formatted
    end
  end

  context 'a citation object with an author' do
    setup do
      @auth = FactoryGirl.build :author, :sur_name=>'Babbit', :given_name=>'Bob'
      @cite = FactoryGirl.build :citation
      @cite.authors << @auth
    end

    should 'not have the author anymore after author_block= is called' do
      assert @cite.authors.include?(@auth)
      @cite.author_block = "Another Author"
      refute @cite.authors.include?(@auth)
    end

    should 'parse authors with double last names' do
      @cite.author_block = "Al Fasir, John"
      @cite.save
      assert_equal 'John', @cite.authors[0].given_name
      assert_equal '', @cite.authors[0].middle_name
      assert_equal "Al Fasir", @cite.authors[0].sur_name
      assert_equal "Al Fasir, John", @cite.author_block
    end

    should 'parse a normal author' do
      @cite.author_block = "Jones, Jonathon"
      @cite.save
      assert_equal "Jones, Jonathon", @cite.author_block
      assert_equal "Jones", @cite.authors[0].sur_name
    end

    #TODO: figure out a way to keep the id's with the authors so they can be just updated and do not need
    # to be replaced.
    # should 'keep the same author record when updating' do
    #   @cite.author_block = 'Babbit, Bob'
    #   @cite.save
    #   assert_equal @auth, @cite.authors[0]
    # end

    # should 'keep the same author when abbreviated' do
    #   @cite.author_block = 'Babbit, B.'
    #   @cite.save
    #   assert_equal @auth, @cite.authors[0]
    # end
  end

  context 'a citation object with many authors' do
    setup do
      @cite = FactoryGirl.create(:citation)
      @cite.authors = []
      4.times do 
        @cite.authors << FactoryGirl.build(:author, :given_name=>'Jon', :sur_name => 'Jones')
      end
      @cite.save
    end

    should 'use et. al. in the style' do
      assert_match( /, et\.al\./, @cite.formatted)
    end

    should 'use all authors if called with long_formatted' do
      refute_match(/et\.al/, @cite.formatted(:long=>true))
    end

    should 'use natural order for second and subsequent authors in long format' do
      assert_match /Jones, J., J. Jones, J. Jones/, @cite.formatted(:long=>true)
    end

  end
end




# == Schema Information
#
# Table name: citations
#
#  id                      :integer         not null, primary key
#  title                   :text
#  abstract                :text
#  pub_date                :date
#  pub_year                :integer
#  citation_type_id        :integer
#  address                 :text
#  notes                   :text
#  publication             :string(255)
#  start_page_number       :integer
#  ending_page_number      :integer
#  periodical_full_name    :text
#  periodical_abbreviation :string(255)
#  volume                  :string(255)
#  issue                   :string(255)
#  city                    :string(255)
#  publisher               :string(255)
#  secondary_title         :string(255)
#  series_title            :string(255)
#  isbn                    :string(255)
#  doi                     :string(255)
#  full_text               :text
#  publisher_url           :string(255)
#  website_id              :integer
#  created_at              :datetime
#  updated_at              :datetime
#  pdf_file_name           :string(255)
#  pdf_content_type        :string(255)
#  pdf_file_size           :integer
#  pdf_updated_at          :datetime
#  state                   :string(255)
#  open_access             :boolean         default(FALSE)
#  type                    :string(255)
#

