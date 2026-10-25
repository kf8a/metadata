# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatatablesHelper do
  describe '#expandable_html' do
    it 'returns short text unchanged' do
      html = '<p>Short abstract.</p>'.html_safe

      expect(helper.expandable_html(html)).to eq html
    end

    it 'collapses long text to an excerpt that expands to the full HTML' do
      html = "<p>#{'word ' * 300}<a href=\"/x\">link</a></p>".html_safe

      result = Nokogiri::HTML.fragment(helper.expandable_html(html, length: 100))

      expect(result.at('details.expandable')).to be_present
      expect(result.at('summary .excerpt').text.length).to be <= 100
      expect(result.at('summary .expand-more').text).to eq ' more'
      expect(result.at('details > p a[href="/x"]')).to be_present
    end
  end
end
