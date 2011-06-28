require 'spec_helper'

describe CitationsController do
  render_views

  before(:each) do
    @website = Website.find_or_create_by_name('lter')
    @controller.current_user = nil

      author1 = Factory.create(:author, :sur_name => 'Zebedee', :seniority => 1)
      author2 = Factory.create(:author, :sur_name => 'Alfred',  :seniority => 1)
      @citation1 = ArticleCitation.new
      @citation1.authors << Author.new( :sur_name => 'Loecke',
                                     :given_name => 'T', :middle_name => 'D',
                                     :seniority => 1)

      @citation1.authors << Author.new(:sur_name => 'Robertson',
                                    :given_name => 'G', :middle_name => 'P',
                                    :seniority => 2)

      @citation1.title = 'Soil resource heterogeneity in the form of aggregated litter alters maize productivity'
      @citation1.publication = 'Plant and Soil'
      @citation1.volume = '325'
      @citation1.start_page_number = 231
      @citation1.ending_page_number = 241
      @citation1.pub_year = 2008
      @citation1.abstract = 'An abstract of the article.'
      @citation1.website = @website
      @citation1.save
      @citation1.publish!

    another_citation = @website.citations.new
    another_citation.save
    another_citation.publish!
  end

  describe 'GET :filtered, sort_by => id' do
    before(:each) do
      get :filtered, :requested_subdomain => 'lter', :sort_by => 'id'
    end

    it { should render_template('filtered') }
    it "should order the citations by id" do
      assigns(:website).should == @website
      correct_sorting = @website.citations.order('id').published
      assigns(:citations).all.should eq correct_sorting.all
    end
  end
end
