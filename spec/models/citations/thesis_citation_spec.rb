require 'rails_helper'

describe ThesisCitation do
  it { should_not be_book }
  its(:bibtex_type) { should == :thesis }
  its(:endnote_type) { should == "Thesis\n" }
  its(:endnote_publication_data) { should == "" }

  it 'is formatted correctly' do
    thesis = ThesisCitation.new
    allow(thesis).to receive(:author_and_year).and_return 'Ladoni, M. 2015.'
    allow(thesis).to receive(:title).and_return 'Interactive effects of cover crops and topography on soil organic carbon and mineral nitrogen'
    allow(thesis).to receive(:series_title).and_return 'Dissertation'
    allow(thesis).to receive(:publisher).and_return 'Michigan State University'
    allow(thesis).to receive(:city).and_return 'East Lansing, MI, USA'
    expect(thesis.formatted).to eq "Ladoni, M. 2015. Interactive effects of cover crops and topography on soil organic carbon and mineral nitrogen. Dissertation, Michigan State University, East Lansing, MI, USA."
  end
end
