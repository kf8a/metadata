# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class SponsorsControllerTest < ActionController::TestCase
  context 'GET: show' do
    setup do
      sponsor = FactoryBot.create :sponsor, data_use_statement: 'smoke em if you got em'
      get :show, params: { id: sponsor }
    end

    should respond_with :success

    should 'contain the data_use_statement' do
      assert_select "p", "smoke em if you got em"
    end
  end
end
