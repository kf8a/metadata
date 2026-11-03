# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CitationsHelper, type: :helper do
  describe '#normalize_doi' do
    it 'prefixes https:// when the value starts with doi.org/' do
      expect(helper.normalize_doi('doi.org/10.1234/foo')).to eq('https://doi.org/10.1234/foo')
    end

    it 'leaves https://doi.org URLs unchanged' do
      expect(helper.normalize_doi('https://doi.org/10.1234/foo')).to eq('https://doi.org/10.1234/foo')
    end

    it 'leaves http://doi.org URLs unchanged' do
      expect(helper.normalize_doi('http://doi.org/10.1234/foo')).to eq('http://doi.org/10.1234/foo')
    end

    it 'leaves other http(s) URLs unchanged' do
      expect(helper.normalize_doi('https://example.com/data')).to eq('https://example.com/data')
    end

    it 'wraps bare DOIs with https://doi.org/' do
      expect(helper.normalize_doi('10.1234/foo')).to eq('https://doi.org/10.1234/foo')
    end
  end
end
