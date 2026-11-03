# frozen_string_literal: true

require 'rails_helper'

# A datatable's title may carry simple formatting; anything that could run in the page is removed.
RSpec.describe 'Datatable title on its page', type: :request do
  before { Website.create!(name: 'lter', url: 'lter.kbs.msu.edu') }

  def heading_for(title)
    get datatable_path(FactoryBot.create(:datatable, title:))
    response.parsed_body.at('h1')
  end

  it 'keeps simple formatting and entities' do
    heading = heading_for('N<sub>2</sub>O at 5&deg;C & <em>more</em>')

    expect(heading.inner_html).to include('N<sub>2</sub>O at 5°C &amp; <em>more</em>')
  end

  it 'removes scripts, event handlers and links' do
    heading = heading_for('Soil <script>alert(1)</script><b onclick="x()">carbon</b> <a href="javascript:x()">link</a>')

    expect(heading.css('script, a, [onclick]')).to be_empty
    expect(heading.text).to include('Soil', 'carbon', 'link')
    expect(heading.inner_html).not_to include('alert(1)>', 'onclick', 'javascript:')
  end
end
