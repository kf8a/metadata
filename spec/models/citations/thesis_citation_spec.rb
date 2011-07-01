require 'spec_helper'

describe ThesisCitation do
  it { should_not be_book }
  its(:bibtex_type) { should == :thesis }
  its(:endnote_type) { should == "Thesis\n" }
  its(:endnote_publication_data) { should == "" }

  it 'should be formatted correctly' do
    thesis = ThesisCitation.new
    thesis.stub(:author_and_year) { 'Jones 1981' }
    thesis.stub(:title) { 'Chapter 10' }
    thesis.stub(:publication) { 'Lifetime Books' }
    thesis.stub(:volume_and_page) { '2, 1-10' }
    thesis.formatted.should == "Jones 1981. Chapter 10. Lifetime Books 2, 1-10"
  end
end
