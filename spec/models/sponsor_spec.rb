require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe Sponsor do
  it 'returns the right terms_of_use_url if it exists' do
    sponsor = FactoryGirl.build :sponsor, data_use_statement: "USE", terms_of_use_url: "http"
    expect(sponsor.terms_of_use_path).to eq "http"
  end

  it 'defaults to the sponsor url if the term_of_use_url is missing' do
    sponsor = FactoryGirl.create :sponsor, data_use_statement: "USE" 
    expect(sponsor.terms_of_use_path).to eq "/sponsors/#{sponsor.id}"
  end
end
