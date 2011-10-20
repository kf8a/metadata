require File.expand_path('../../test_helper',__FILE__) 

class ProtocolsControllerTest < ActionController::TestCase

  context 'an admin user' do
    setup do
      generate_websites_and_protocols
      signed_in_as_admin
    end

    context 'GET: new' do
      setup do 
        get :new
      end

      should respond_with(:success)
    end

    context 'GET :edit' do
      setup do
        get :edit, :id => @protocol
      end

      should respond_with(:success)
    end

    context 'POST: create' do
      setup do
        post :create, :protocol => {:dataset_id => 35 }
      end
     should redirect_to('the protocol show page') {protocol_path(assigns(:protocol))}
    end

    context 'POST with website' do
      setup do
        @protocol = Factory.create(:protocol)
        post :create, :id => @protocol, :websites=>['2']
      end

      should assign_to :protocol
      should redirect_to("the show page") {protocol_url(assigns(:protocol))}
    end

    context 'PUT :update' do
      setup do
        put :update, :id => @protocol, :protocol => {:description => 'A brand new description'}
      end

      should redirect_to('the protocol page') {protocol_url(assigns(:protocol))}
      should "record the user who changed the protocol" do
        assert_equal @admin, @protocol.versions.last.user
      end
    end

    context 'POST: update with version' do
      setup do 
        put :update, :id => @protocol, :protocol => {:title => 'new protocol'}, :new_version => "1"
      end

      should 'create a new protocol' do
        assert_not_equal @protocol, assigns(:protocol)
      end

      should 'depreate the old protocol' do
        assert_equal @protocol.id, assigns(:protocol).deprecates
        assert_equal true, assigns(:protocol).active?
        assert_equal false, Protocol.find(@protocol).active?
      end

      should redirect_to('the new protocol') {protocol_path(assigns(:protocol))}

    end

    context 'DESTROY' do
      setup do
        delete :destroy, :id => @protocol
      end

      should redirect_to('the index page') {protocols_path}
    end
  end

  context 'a anonymous user' do
    setup do
      generate_websites_and_protocols
      @controller.current_user = nil
    end

    context 'GET: index in lter (default) subdomain' do
      setup do
        Rails.cache.clear
        get :index, :requested_subdomain => 'lter'
      end

      should render_template 'index'

      should 'only have lter protocols' do
        assert assigns(:protocols) == [@protocol]
      end
    end

    context "GET :index / glbrc subdomain" do
      setup do
        Rails.cache.clear
        get :index, :requested_subdomain => 'glbrc'
      end

      should 'only have glbrc protocols' do
        assert assigns(:protocols) == [@glbrc_protocol]
      end
    end

    context 'GET :show in glbrc subdomain with lter_protocol' do
      setup do
        get :show, :id => @protocol, :requested_subdomain => 'glbrc'
      end

      should redirect_to("the index page") {protocols_url()}
    end

    context 'GET :show in glbrc subdomain with glbrc protocol' do
      setup do 
        get :show, :id => @glbrc_protocol, :requested_subdomain => 'glbrc'
      end

      should respond_with(:success)
    end

    context 'POST: create' do
      setup do
        post :create, :protocol => {:dataset_id => 35 }
      end

      should redirect_to('the sign in page') {sign_in_path}
    end

    context 'GET: new' do
      setup do 
        get :new
      end

      should redirect_to('the sign in page') {sign_in_path}
    end

    context 'GET: show' do
      setup do
        get :show, :id=> @protocol
      end

      should respond_with(:success)
    end

    context 'GET: edit' do
      setup do
        get :edit, :id => @protocol
      end

      should redirect_to('the sign in page') {sign_in_url}
    end
  end

  private

  def generate_websites_and_protocols
    @website = Website.find_by_name('lter')
    @protocol = Factory.create(:protocol, :title => 'lter_protocol')
    @website.protocols << @protocol
    
    @glbrc_website = Website.find_by_name('glbrc')
    @glbrc_protocol = Factory.create(:protocol, :title => 'glbrc protocol')
    @glbrc_website.protocols << @glbrc_protocol
  end

end
