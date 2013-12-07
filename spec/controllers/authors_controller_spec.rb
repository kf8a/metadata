require 'spec_helper'

describe AuthorsController do
  render_views

  before(:each) do
    @controller.current_user = FactoryGirl.create :admin_user
  end

  describe 'GET :index, :format => :json' do
    before(:each) do
      @author = FactoryGirl.create :author
      get :index, :format => :json
    end

    it { response.status.should == 200 }
  end
end
