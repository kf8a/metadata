require 'spec_helper'

describe ThesisCitation do
  it { should_not be_book }
  its(:bibtex_type) { should == :thesis }
  its(:endnote_type) { should == "Thesis\n" }
  its(:endnote_publication_data) { should == "" }

  it 'is formatted correctly' do
    thesis = ThesisCitation.new
    thesis.stub(:author_and_year) {'Ladoni, M. 2015.'}
    thesis.stub(:title) {'Interactive effects of cover crops and topography on soil organic carbon and mineral nitrogen'}
    thesis.stub(:series_title) {'Dissertation'}
    thesis.stub(:publisher) {'Michigan State University'}
    thesis.stub(:address) { ''}
    thesis.stub(:city) {'East Lansing, MI, USA'}
    expect(thesis.formatted).to eq "Ladoni, M. 2015. Interactive effects of cover crops and topography on soil organic carbon and mineral nitrogen. Dissertation, Michigan State University, East Lansing, MI, USA."
  end
end
