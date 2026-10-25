# frozen_string_literal: true

require 'rails_helper'

describe AbstractsController, type: :controller do
  before do
    sign_in FactoryBot.create(:admin_user)
    @abstract = FactoryBot.create(:abstract)
  end

  describe 'DELETE destroy' do
    it 'responds with an empty 200 for js requests' do
      delete :destroy, params: { id: @abstract.id }, format: :js

      expect(response).to have_http_status(:ok)
      expect(response.body).to be_empty
      expect(Abstract.exists?(@abstract.id)).to be false
    end
  end
end
