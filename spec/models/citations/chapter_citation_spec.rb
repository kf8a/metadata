require 'spec_helper'

describe ChapterCitation do
  it { should_not be_book }
  its(:bibtex_type) { should == :thesis }
  its(:endnote_type) { should == "Thesis\n" }
  its(:endnote_publication_data) { should == "" }

  it 'should be formatted correctly' do
    chapter = ChapterCitation.new
    chapter.stub(:author_and_year) { 'Jones 1981' }
    chapter.stub(:title) { 'Chapter 10' }
    chapter.stub(:publication) { 'Lifetime Books' }
    chapter.stub(:volume_and_page) { '2, 1-10' }
    chapter.formatted.should == "Jones 1981. Chapter 10. Lifetime Books 2, 1-10"
  end
end
