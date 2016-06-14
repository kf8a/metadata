require 'rails_helper'

describe ConferenceCitation do
  it { should_not be_book }
  its(:bibtex_type) { should == :thesis }
  its(:endnote_type) { should == "Thesis\n" }
  its(:endnote_publication_data) { should == '' }

  it 'should be formatted correctly' do
    conference = ConferenceCitation.new
    allow(conference).to receive(:author_and_year).and_return 'Jones 1981.'
    allow(conference).to receive(:title).and_return 'Chapter 10'
    allow(conference).to receive(:publication).and_return 'Lifetime Books'
    allow(conference).to receive(:volume_and_page).and_return '2, 1-10'
    expect(conference.formatted).to eq 'Jones 1981. Chapter 10. Lifetime Books 2, 1-10'
  end
end
