require 'spec_helper'

describe ChapterCitation do
  it { should_not be_book }
  its(:bibtex_type) { should == :chapter }
  its(:endnote_type) { should == "CHAP\n" }
  its(:endnote_publication_data) { should == "" }

  describe 'formatting' do
    before do 
      @chapter = ChapterCitation.new
      @chapter.stub(:author_and_year) { 'Jones 1981' }
      @chapter.stub(:title) { 'Chapter 10' }
      @chapter.stub(:publication) { 'Lifetime Books' }
    end

    it 'should be formatted correctly with volume and pages' do
      @chapter.stub(:volume) { '2' }
      @chapter.stub(:start_page_number) {'1'}
      @chapter.stub(:ending_page_number) {'10'}
      @chapter.formatted.should == "Jones 1981. Chapter 10. Lifetime Books, vol 2, pages 1-10."
    end

    it 'should be formatted correctly without volume' do
      @chapter.stub(:start_page_number) {'1'}
      @chapter.stub(:ending_page_number) {'10'}
      @chapter.formatted.should == "Jones 1981. Chapter 10. Lifetime Books, pages 1-10."
    end
  end
end
