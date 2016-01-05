require 'rails_helper'

describe EbookCitation do
  it { should_not be_book }
  its(:bibtex_type) { should == :thesis }
  its(:endnote_type) { should == "Thesis\n" }
  its(:endnote_publication_data) { should == "" }

  it 'should be formatted correctly' do
    ebook = EbookCitation.new
    allow(ebook).to receive(:author_and_year).and_return 'Jones 1981.'
    allow(ebook).to receive(:title).and_return 'Chapter 10'
    allow(ebook).to receive(:publication).and_return 'Lifetime Books'
    allow(ebook).to receive(:volume_and_page).and_return '2, 1-10'
    expect(ebook.formatted).to eq "Jones 1981. Chapter 10. Lifetime Books 2, 1-10"
  end
end
