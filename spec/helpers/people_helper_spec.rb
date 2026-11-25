# frozen_string_literal: true

require 'rails_helper'

describe PeopleHelper, type: :helper do
  describe '#contact_link' do
    it 'should change @ to at' do
      unmodified_email = 'sam@example.com'
      fixed_email = 'sam at example.com'
      expect(helper.contact_link(unmodified_email)).to eq(fixed_email)
    end
  end

  describe '#show_committee' do
    let(:role) { FactoryBot.create(:role) }

    def join(committee, name, left_on: nil)
      person = FactoryBot.create(:person, sur_name: name, given_name: 'Ada')
      FactoryBot.create(:affiliation, person:, role:, title: committee, left_on:)
      person
    end

    it 'lists the current members of the committee as links to their pages' do
      first = join('Science Council', 'Smith')
      second = join('Science Council', 'Jones')
      join('Science Council', 'Gone', left_on: Date.new(2020, 1, 1))
      join('Climate', 'Elsewhere')

      html = helper.show_committee('Science Council', role)

      expect(html).to be_html_safe
      expect(html).to start_with('<li>Science Council:  ')
      expect(html).to include(%(href="#{person_path(first)}"), %(href="#{person_path(second)}"))
      expect(html).not_to include('Gone', 'Elsewhere')
    end

    it 'escapes names and the committee, which the view no longer marks as safe' do
      join('R&D <b>board</b>', 'O<script>alert(1)</script>Brien')

      html = helper.show_committee('R&D <b>board</b>', role)

      expect(html).to include('R&amp;D &lt;b&gt;board&lt;/b&gt;:', '&lt;script&gt;alert(1)&lt;/script&gt;')
      expect(html).not_to include('<script>', '<b>board')
    end
  end
end
