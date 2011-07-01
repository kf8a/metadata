require 'spec_helper'

describe ReportCitation do
  it { should_not be_book }
  its(:bibtex_type) { should == :thesis }
  its(:endnote_type) { should == "Thesis\n" }
  its(:endnote_publication_data) { should == "" }

  it 'should be formatted correctly' do
    report = ReportCitation.new
    report.stub(:author_and_year) { 'Jones 1981' }
    report.stub(:title) { 'Chapter 10' }
    report.stub(:publication) { 'Lifetime Books' }
    report.stub(:volume_and_page) { '2, 1-10' }
    report.formatted.should == "Jones 1981. Chapter 10. Lifetime Books 2, 1-10"
  end
end
