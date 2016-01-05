require 'rails_helper'

describe BulletinCitation do
  its(:bibtex_type) { should == :report}
  its(:endnote_type) { should == "Pamphlet\n" }
  its(:endnote_publication_data) { should == "" }


  it 'should be formatted correctly' do
    report = BulletinCitation.new
    allow(report).to receive(:author_and_year).and_return 'Snapp, S. S., and V. L. Morrone. 2014.'
    allow(report).to receive(:title).and_return 'Perennial wheat'
    allow(report).to receive(:publisher).and_return "Michigan State University"
    allow(report).to receive(:city).and_return 'East Lansing, Michigan, USA'
    allow(report).to receive(:publication).and_return 'MSU Extension Bulletin E-3208'
    expect(report.formatted).to eq "Snapp, S. S., and V. L. Morrone. 2014. Perennial wheat. MSU Extension Bulletin E-3208, Michigan State University, East Lansing, Michigan, USA."
  end
end

