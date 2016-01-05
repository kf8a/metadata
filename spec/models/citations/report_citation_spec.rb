require 'rails_helper'

describe ReportCitation do
  it { should_not be_book }
  its(:bibtex_type) { should == :report}
  its(:endnote_type) { should == "Report\n" }
  its(:endnote_publication_data) { should == "" }

  it 'should be formatted correctly' do
    report = ReportCitation.new
    allow(report).to receive(:author_and_year).and_return 'Jones 1981.'
    allow(report).to receive(:title).and_return 'Chapter 10'
    allow(report).to receive(:publication).and_return 'Lifetime Books'
    allow(report).to receive(:volume_and_page).and_return '2, 1-10'
    expect(report.formatted).to eq "Jones 1981. Chapter 10. Lifetime Books. 2, 1-10."
  end

  it 'should be formatted correctly' do
    report = ReportCitation.new
    allow(report).to receive(:author_and_year).and_return 'Millar, N., G. P. Robertson, A. Diamant, R. J. Gehl, P. R. Grace, and J. P. Hoben. 2013.'
    allow(report).to receive(:title).and_return 'Quantifying N2O emissions reductions in US agricultural crops through N fertilizer rate reduction'
    allow(report).to receive(:city).and_return 'Washington, DC, USA'
    allow(report).to receive(:publication).and_return 'Verified Carbon Standard'
    expect(report.formatted).to eq "Millar, N., G. P. Robertson, A. Diamant, R. J. Gehl, P. R. Grace, and J. P. Hoben. 2013. Quantifying N2O emissions reductions in US agricultural crops through N fertilizer rate reduction. Verified Carbon Standard. Washington, DC, USA."
  end

  it 'should format a report with a publisher correctly' do
    report = ReportCitation.new
    allow(report).to receive(:author_and_year).and_return "Eagle, A. J., L. R. Henry, L. P. Olander, K. Haugen-Kozyra, N. Millar, and G. P. Robertson. 2012."
    allow(report).to receive(:title).and_return "Greenhouse gas mitigation potential of agricultural land management in the United States: a synthesis of the literature. Third Edition"
    allow(report).to receive(:city).and_return "Durham, North Carolina, USA"
    allow(report).to receive(:publisher).and_return "Nicholas Institute for Environmental Policy Solutions"
    expect(report.formatted).to eq "Eagle, A. J., L. R. Henry, L. P. Olander, K. Haugen-Kozyra, N. Millar, and G. P. Robertson. 2012. Greenhouse gas mitigation potential of agricultural land management in the United States: a synthesis of the literature. Third Edition. Nicholas Institute for Environmental Policy Solutions, Durham, North Carolina, USA."
  end
end
