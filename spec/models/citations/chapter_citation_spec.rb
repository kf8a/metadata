require 'spec_helper'

describe ChapterCitation do
  it { should_not be_book }
  its(:bibtex_type) { should == :chapter }
  its(:endnote_type) { should == "CHAP\n" }
  its(:endnote_publication_data) { should == "" }

  describe 'formatting' do
    before do 
      @chapter = ChapterCitation.new
      @chapter.stub(:author_and_year) { 'Jones 1981.' }
      @chapter.stub(:title) { 'Chapter 10' }
      @chapter.stub(:publication) { 'Lifetime Books' }
    end

    it 'should be formatted correctly with volume and pages' do
      @chapter.stub(:volume) { '2' }
      @chapter.stub(:start_page_number) {'1'}
      @chapter.stub(:ending_page_number) {'10'}
      @chapter.formatted.should == "Jones 1981. Chapter 10. Vol 2, Pages 1-10 in Lifetime Books."
    end

    it 'should be formatted correctly without volume' do
      @chapter.stub(:start_page_number) {'1'}
      @chapter.stub(:ending_page_number) {'10'}
      @chapter.formatted.should == "Jones 1981. Chapter 10. Pages 1-10 in Lifetime Books."
    end
  end

  it 'should be formatted correctly with editors' do
    @chapter.stub(:author_and_year) {"Pryor, S. C., D. Scavia, C. Downer, M. Gaden, L. Iverson, R. Nordstrom, J. Patz, and G. P. Robertson. 2014."}
    @chapter.stub(:publication) {"Climate change impacts in the United States: The Third National Climate Assessment"}
    @chapter.formatted.should == "Pryor, S. C., D. Scavia, C. Downer, M. Gaden, L. Iverson, R. Nordstrom, J. Patz, and G. P. Robertson. 2014. Chapter 18: Midwest. Pages 418-440 in J. M. Melillo, T. C. Richmond, and G. W. Yohe, eds. Climate change impacts in the United States: The Third National Climate Assessment. U.S. Global Change Research Program, doi:10.7930/J0J1012N"
  end
end
