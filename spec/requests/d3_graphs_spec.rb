# frozen_string_literal: true

require 'rails_helper'

# Score cards and QC graphs are drawn by Stimulus controllers with d3; check
# the markup hands them their data and the old Protovis scripts are gone.
RSpec.describe 'd3 graphs', type: :request do
  before { Website.create!(name: 'lter', url: 'lter.kbs.msu.edu') }

  def page
    response.parsed_body
  end

  let(:datatable) { FactoryBot.create(:datatable) }

  it 'points each QC graph at its visualization data' do
    visualization = FactoryBot.create(:visualization, datatable:, graph_type: 'dot-graph',
                                                      y_axis_label: 'Air temperature (C)')

    get qc_datatable_path(datatable)

    graph = page.at('[data-controller="qc-graph"]')
    expect(graph['data-qc-graph-url-value']).to eq visualization_path(visualization, format: :json)
    expect(graph['data-qc-graph-type-value']).to eq 'dot-graph'
    expect(graph['data-qc-graph-y-label-value']).to eq 'Air temperature (C)'
  end

  it 'serves visualization rows as JSON' do
    visualization = FactoryBot.create(:visualization,
                                      query: "select '2020-01-01 00:00:00' as datetime, 1.5 as value")

    get visualization_path(visualization, format: :json)

    expect(response.parsed_body).to eq [{ 'datetime' => '2020-01-01 00:00:00', 'value' => '1.5' }]
  end

  it 'hands the score card its yearly scores' do
    datatable.update!(scores: [{ year: 2020, count: 10, approved: 8 }].to_json)

    get score_card_path(datatable)

    card = page.at('[data-controller="score-card"]')
    expect(JSON.parse(card['data-score-card-scores-value'])).to eq [{ 'year' => 2020, 'count' => 10, 'approved' => 8 }]
  end

  it 'gives a score card without scores an empty list' do
    get score_card_path(datatable)

    expect(page.at('[data-controller="score-card"]')['data-score-card-scores-value']).to eq '[]'
  end

  it 'loads d3 instead of the legacy graph scripts' do
    get qc_datatable_path(datatable)

    importmap = JSON.parse(page.at('script[type="importmap"]').text)['imports']
    expect(importmap).to include('d3', 'controllers/qc_graph_controller', 'controllers/score_card_controller')
    expect(importmap.keys.grep(/legacy|protovis|proto-graphs|scores/)).to be_empty
  end
end
