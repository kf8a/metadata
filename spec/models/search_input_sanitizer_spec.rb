require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe SearchInputSanitizer do
  it 'removes unsafe characters' do
    expect(SearchInputSanitizer.sanitize('=>45\\')).to eq '45'
  end
end
