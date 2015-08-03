require 'rails_helper'

describe ReportCitation do
  it { should_not be_book }
  its(:bibtex_type) { should == :report}
  its(:endnote_type) { should == "Report\n" }
  its(:endnote_publication_data) { should == "" }

  it 'should be formatted correctly' do
    report = ReportCitation.new
    report.stub(:author_and_year) { 'Jones 1981.' }
    report.stub(:title) { 'Chapter 10' }
    report.stub(:publication) { 'Lifetime Books' }
    report.stub(:volume_and_page) { '2, 1-10' }
    report.formatted.should == "Jones 1981. Chapter 10. Lifetime Books. 2, 1-10."
  end

  it 'should be formatted correctly' do
    report = ReportCitation.new
    report.stub(:author_and_year) {'Millar, N., G. P. Robertson, A. Diamant, R. J. Gehl, P. R. Grace, and J. P. Hoben. 2013.'}
    report.stub(:title) {'Quantifying N2O emissions reductions in US agricultural crops through N fertilizer rate reduction'}
    report.stub(:city) {'Washington, DC, USA'}
    report.stub(:publication) {'Verified Carbon Standard'}
    report.formatted.should == "Millar, N., G. P. Robertson, A. Diamant, R. J. Gehl, P. R. Grace, and J. P. Hoben. 2013. Quantifying N2O emissions reductions in US agricultural crops through N fertilizer rate reduction. Verified Carbon Standard. Washington, DC, USA."
  end

  it 'should format a report with a publisher correctly' do
    report = ReportCitation.new
    report.stub(:author_and_year) {"Eagle, A. J., L. R. Henry, L. P. Olander, K. Haugen-Kozyra, N. Millar, and G. P. Robertson. 2012."}
    report.stub(:title) {"Greenhouse gas mitigation potential of agricultural land management in the United States: a synthesis of the literature. Third Edition"}
    report.stub(:city) {"Durham, North Carolina, USA"}
    report.stub(:publisher) {"Nicholas Institute for Environmental Policy Solutions"}
    report.formatted.should == "Eagle, A. J., L. R. Henry, L. P. Olander, K. Haugen-Kozyra, N. Millar, and G. P. Robertson. 2012. Greenhouse gas mitigation potential of agricultural land management in the United States: a synthesis of the literature. Third Edition. Nicholas Institute for Environmental Policy Solutions, Durham, North Carolina, USA."
  end
end
