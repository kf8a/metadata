# frozen_string_literal: true

require 'rails_helper'

# A datatable's title is plain text: markup in it is shown, not run.
RSpec.describe 'Datatable title on its page', type: :request do
  before { Website.create!(name: 'lter', url: 'lter.kbs.msu.edu') }

  it 'escapes the title in the heading' do
    datatable = FactoryBot.create(:datatable, title: 'Soil <script>alert(1)</script> & water')

    get datatable_path(datatable)

    heading = response.parsed_body.at('h1').inner_html
    expect(heading).to include('Soil &lt;script&gt;alert(1)&lt;/script&gt; &amp; water')
    expect(response.parsed_body.css('h1 script')).to be_empty
  end
end
