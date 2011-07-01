require 'spec_helper'

describe EbookCitation do
  it { should_not be_book }
  its(:bibtex_type) { should == :thesis }
  its(:endnote_type) { should == "Thesis\n" }
  its(:endnote_publication_data) { should == "" }

  it 'should be formatted correctly' do
    ebook = EbookCitation.new
    ebook.stub(:author_and_year) { 'Jones 1981' }
    ebook.stub(:title) { 'Chapter 10' }
    ebook.stub(:publication) { 'Lifetime Books' }
    ebook.stub(:volume_and_page) { '2, 1-10' }
    ebook.formatted.should == "Jones 1981. Chapter 10. Lifetime Books 2, 1-10"
  end
end
