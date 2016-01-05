require 'rails_helper'

describe ConferenceCitation do
  it { should_not be_book }
  its(:bibtex_type) { should == :thesis }
  its(:endnote_type) { should == "Thesis\n" }
  its(:endnote_publication_data) { should == "" }

  it 'should be formatted correctly' do
    conference = ConferenceCitation.new
    conference.stub(:author_and_year) { 'Jones 1981.' }
    conference.stub(:title) { 'Chapter 10' }
    conference.stub(:publication) { 'Lifetime Books' }
    conference.stub(:volume_and_page) { '2, 1-10' }
    expect(conference.formatted).to eq "Jones 1981. Chapter 10. Lifetime Books 2, 1-10"
  end
end
