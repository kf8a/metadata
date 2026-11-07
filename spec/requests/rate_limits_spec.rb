# frozen_string_literal: true

require 'rails_helper'

# Per-IP request limits (config/initializers/rack_attack.rb): 8 a second on everything but assets, and 15 a
# minute each on signing in and on searches, downloads and data queries.
RSpec.describe 'Rate limits', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:start) { Time.zone.local(2026, 11, 7, 12, 0, 0) } # the start of a counting window

  before do
    Website.create!(name: 'lter', url: 'lter.kbs.msu.edu')
    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    travel_to(start)
  end

  after { Rack::Attack.enabled = false }

  def visit(path, ip: '203.0.113.7', method: :get)
    public_send(method, path, env: { 'REMOTE_ADDR' => ip })
    response.status
  end

  # One request a second, so only the per-minute limits can be reached
  def slowly(count, path, **)
    Array.new(count) do
      visit(path, **).tap { travel(1.second) }
    end
  end

  describe 'per second' do
    it 'allows 8 requests in a second and refuses the 9th, saying when to come back' do
      statuses = Array.new(9) { visit('/users/sign_in') }

      expect(statuses.first(8)).to all(be < 429)
      expect(statuses.last).to eq 429
      expect(response.headers['Retry-After']).to eq '1'
      expect(response.body).to include('Too many requests')
    end

    it 'starts over in the next second' do
      9.times { visit('/users/sign_in') }
      travel(1.second)

      expect(visit('/users/sign_in')).to be < 429
    end

    it 'counts each client separately' do
      9.times { visit('/users/sign_in', ip: '203.0.113.1') }

      expect(visit('/users/sign_in', ip: '203.0.113.2')).to be < 429
    end

    it 'counts the address nginx forwards, so a forged first X-Forwarded-For entry does not dodge the limit' do
      statuses = (1..9).map do |n|
        forwarded = "198.51.100.#{n}, 203.0.113.7"
        get '/users/sign_in', env: { 'REMOTE_ADDR' => '127.0.0.1', 'HTTP_X_FORWARDED_FOR' => forwarded }
        response.status
      end

      expect(statuses.last).to eq 429
    end

    it 'does not count assets' do
      path = "#{Rails.application.config.assets.prefix}/application.css"

      expect(Array.new(20) { visit(path) }).not_to include(429)
    end
  end

  describe 'per minute' do
    it 'allows 15 downloads, searches and data queries a minute, then refuses more' do
      statuses = slowly(16, '/datatables/1.csv')

      expect(statuses.first(15)).to all(be < 429)
      expect(statuses.last).to eq 429
      expect(visit('/citations/search')).to eq 429 # the same budget
    end

    it 'allows 15 sign-in attempts a minute, then refuses more' do
      statuses = slowly(16, '/users/sign_in', method: :post)

      expect(statuses.first(15)).to all(be < 429)
      expect(statuses.last).to eq 429
    end

    it 'keeps sign-ins and costly requests on separate budgets, and leaves ordinary pages alone' do
      slowly(16, '/datatables/1.csv')

      expect(visit('/users/sign_in', method: :post)).to be < 429
      expect(visit('/users/password/new')).to be < 429
    end

    it 'starts over the next minute' do
      slowly(16, '/datatables/1.csv')
      travel_to(start + 2.minutes)

      expect(visit('/datatables/1.csv')).to be < 429
    end
  end
end
