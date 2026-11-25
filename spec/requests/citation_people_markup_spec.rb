# frozen_string_literal: true

require 'rails_helper'

# Citation pages and the people directory print text from records: simple formatting in a citation stays,
# and anything that could run in the page, or a link that is not a web address, is dropped.
RSpec.describe 'Markup from citation and people records', type: :request do
  before { Website.create!(name: 'lter', url: 'lter.kbs.msu.edu') }

  describe 'a citation page' do
    def citation(attributes = {})
      FactoryBot.create(:article_citation, state: 'published', pub_year: 2020, **attributes)
    end

    it 'keeps simple formatting in the citation and removes scripts' do
      get citation_path(citation(title: 'Soil N<sub>2</sub>O <script>alert(1)</script> <i onclick="x()">flux</i>'))

      heading = response.parsed_body.at('h2')
      expect(heading.inner_html).to include('N<sub>2</sub>O', '<i>flux</i>')
      expect(heading.css('script, [onclick]')).to be_empty
    end

    it 'keeps a title from breaking out of the page data' do
      get citation_path(citation(title: '</script><script>alert(1)</script>'))

      scripts = response.parsed_body.css('script').reject { |script| script['type'] == 'application/ld+json' }
      data = response.parsed_body.at('script[type="application/ld+json"]').text
      expect(scripts.map(&:text).join).not_to include('alert(1)')
      expect(JSON.parse(data)['headline']).to eq '</script><script>alert(1)</script>'
    end

    it 'links the publisher only when the address is a web address' do
      get citation_path(citation(publisher_url: 'javascript:alert(1)'))
      expect(response.parsed_body.css('a').map { |link| link['href'].to_s }).not_to include(/javascript:/i)

      get citation_path(citation(publisher_url: 'https://publisher.example.org/paper'))
      expect(response.parsed_body.css('a[href="https://publisher.example.org/paper"]')).not_to be_empty
    end
  end

  describe 'the people directory' do
    it 'lists committee members as links, with names escaped' do
      role = FactoryBot.create(:role, id: 23, name: 'Committees', role_type: RoleType.create!(name: 'lter'))
      person = FactoryBot.create(:person, sur_name: 'O<script>alert(1)</script>Brien', given_name: 'Ada')
      FactoryBot.create(:affiliation, person:, role:, title: 'Science Council')

      get people_path

      item = response.parsed_body.css('li').find { |li| li.text.start_with?('Science Council:') }
      expect(item.at("a[href='#{person_path(person)}']")).to be_present
      expect(item.css('script')).to be_empty
      expect(item.text).to include('<script>alert(1)</script>')
    end
  end
end
