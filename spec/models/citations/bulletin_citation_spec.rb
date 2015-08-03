require 'rails_helper'

describe BulletinCitation do
  its(:bibtex_type) { should == :report}
  its(:endnote_type) { should == "Pamphlet\n" }
  its(:endnote_publication_data) { should == "" }


  it 'should be formatted correctly' do
    report = BulletinCitation.new
    report.stub(:author_and_year) {'Snapp, S. S., and V. L. Morrone. 2014.'}
    report.stub(:title) {'Perennial wheat'}
    report.stub(:publisher) {"Michigan State University"}
    report.stub(:city) {'East Lansing, Michigan, USA'}
    report.stub(:publication) {'MSU Extension Bulletin E-3208'}
    report.formatted.should == "Snapp, S. S., and V. L. Morrone. 2014. Perennial wheat. MSU Extension Bulletin E-3208, Michigan State University, East Lansing, Michigan, USA."
  end
end

