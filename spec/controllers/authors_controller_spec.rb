require 'rails_helper'

describe AuthorsController, type: :controller do
  render_views

  before(:each) do
    sign_in User.new
  end

  describe 'GET :index, :format => :json' do
    before(:each) do
      @author = FactoryBot.build :author
      get :index, format: :json
    end

    it { expect(response.status).to eq 200 }
  end
end
