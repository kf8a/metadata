require 'spec_helper'

describe AuthorsController do
  render_views

  before(:each) do
    @controller.current_user = Factory.create :admin_user
  end

  describe 'GET :index, :format => :json' do
    before(:each) do
      @author = Factory.create :author
      get :index, :format => :json
    end

    it { should assign_to :authors }
  end
end
