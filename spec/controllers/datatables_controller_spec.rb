require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe DatatablesController, type: :controller  do

  def mock_datatable(stubs={})
    @mock_datatable ||= stub_model(Datatable)
    @mock_datatable.should_receive(:dataset).at_least(1).and_return(mock_dataset)
    @mock_datatable.should_receive(:is_sql).and_return(:true)
    @mock_datatable.should_receive(:is_restricted).and_return(:false)
    @mock_datatable.should_receive(:object).and_return("select * from datatables")
    @mock_datatable.should_receive(:study)
    @mock_dataset.should_receive(:title).and_return('title')
    @mock_datatable
  end

  def mock_dataset(stubs={})
    @mock_dataset ||= stub_model(Dataset)
  end

  before do
    @user = FactoryGirl.build(:admin_user)
    sign_in_as @user
  end

  describe "responding to GET index" do

    it "should return an empty array" do
      get :index
      assigns[:datatables].should == []
    end
  end

  describe 'responding to publish request' do
    it 'should publish' do
      datatable = Datatable.new
      allow(datatable).to receive(:object).and_return('select now() as sample_date')
      allow(datatable).to receive(:save!).and_return(true)
      expect(Datatable).to receive(:find).with('1').at_least(1).and_return(datatable)
      put :publish, :id => "1"
      response.code.should eq("200")
    end
  end

  # describe "responding to GET show" do

  #   it "should expose the requested datatable as @datatable" do
  #     Datatable.should_receive(:find).with("37").at_least(1).and_return(mock_datatable)
  #     get :show, :id => "37"
  #     assigns[:datatable].should equal(mock_datatable)
  #   end

  #   describe "with mime type of xml" do

  #     it "should render the requested datatable as xml" do
  #       request.env["HTTP_ACCEPT"] = "application/xml"
  #       Datatable.should_receive(:find,:dataset).with("37").at_least(1).and_return(mock_datatable)
  #       mock_datatable.should_receive(:is_sql).and_return(:true)
  #       mock_datatable.should_receive(:is_restricted).and_return(:false)
  #       mock_datatable.should_receive(:object).and_return("select * from datatables")

  #       mock_datatable.should_receive(:to_xml).and_return("generated XML")
  #       get :show, :id => "37"
  #       response.body.should == "generated XML"
  #     end

  #   end

  #   describe 'with a version' do
  #     it 'should retrieve the version requested' do
  #       get :show, :id => 37, :version => 1
  #     end
  #   end

  # end

  # describe "responding to GET new" do

  #   it "should expose a new datatable as @datatable" do
  #     Datatable.should_receive(:new).and_return(mock_datatable)
  #     get :new
  #     assigns[:datatable].should equal(mock_datatable)
  #   end

  # end

  # describe "responding to GET edit" do

  #   it "should expose the requested datatable as @datatable" do
  #     Datatable.should_receive(:find,:dataset).with("37").and_return(mock_datatable)
  #     get :edit, :id => "37"
  #     assigns[:datatable].should equal(mock_datatable)
  #   end

  #   it "should expose a list of datasets as @datasets" do
  #   end

  # end

  # describe "responding to POST create" do

  #   describe "with valid params" do

  #     it "should expose a newly created datatable as @datatable" do
  #       Datatable.should_receive(:new).with({'these' => 'params'}).and_return(mock_datatable(:save => true))
  #       post :create, :datatable => {:these => 'params'}
  #       assigns(:datatable).should equal(mock_datatable)
  #     end

  #     it "should redirect to the created datatable" do
  #       Datatable.stub!(:new).and_return(mock_datatable(:save => true))
  #       post :create, :datatable => {}
  #       response.should redirect_to(datatable_url(mock_datatable))
  #     end

  #   end

  #   describe "with invalid params" do

  #     it "should expose a newly created but unsaved datatable as @datatable" do
  #       Datatable.stub!(:new).with({'these' => 'params'}).and_return(mock_datatable(:save => false))
  #       post :create, :datatable => {:these => 'params'}
  #       assigns(:datatable).should equal(mock_datatable)
  #     end

  #     it "should re-render the 'new' template" do
  #       Datatable.stub!(:new).and_return(mock_datatable(:save => false))
  #       post :create, :datatable => {}
  #       response.should render_template('new')
  #     end

  #   end

  # end

  # describe "responding to PUT udpate" do

  #   describe "with valid params" do

  #     it "should update the requested datatable" do
  #       Datatable.should_receive(:find,:dataset).with("37").and_return(mock_datatable)
  #       mock_datatable.should_receive(:dataset).at_least(1).and_return(mock_dataset)
  #       mock_dataset.should_receive(:title).and_return('title')

  #       mock_datatable.should_receive(:update_attributes).with({'these' => 'params'})
  #       put :update, :id => "37", :datatable => {:these => 'params'}
  #     end

  #     it "should expose the requested datatable as @datatable" do
  #       Datatable.stub!(:find,:dataset).and_return(mock_datatable(:update_attributes => true))
  #       mock_datatable.should_receive(:dataset).at_least(1).and_return(mock_dataset)
  #       mock_dataset.should_receive(:title).and_return('title')

  #       put :update, :id => "1"
  #       assigns(:datatable).should equal(mock_datatable)
  #     end

  #     it "should redirect to the datatable" do
  #       Datatable.stub!(:find,:dataset).and_return(mock_datatable(:update_attributes => true))
  #       mock_datatable.should_receive(:dataset).at_least(1).and_return(mock_dataset)
  #       mock_dataset.should_receive(:title).and_return('title')

  #       put :update, :id => "1"
  #       response.should redirect_to(datatable_url(mock_datatable))
  #     end

  #   end

  #   describe "with invalid params" do

  #     it "should update the requested datatable" do
  #       Datatable.should_receive(:find,:dataset).with("37").and_return(mock_datatable)
  #       mock_datatable.should_receive(:update_attributes).with({'these' => 'params'})
  #       put :update, :id => "37", :datatable => {:these => 'params'}
  #     end

  #     it "should expose the datatable as @datatable" do
  #       Datatable.stub!(:find,:dataset).and_return(mock_datatable(:update_attributes => false))
  #       mock_datatable.should_receive(:dataset).at_least(1).and_return(mock_dataset)
  #       mock_dataset.should_receive(:title).and_return('title')

  #       put :update, :id => "1"
  #       assigns(:datatable).should equal(mock_datatable)
  #     end

  #     it "should re-render the 'edit' template" do
  #       Datatable.stub!(:find, :dataset).and_return(mock_datatable(:update_attributes => false))
  #       mock_datatable.should_receive(:dataset).at_least(1).and_return(mock_dataset)
  #       mock_dataset.should_receive(:title).and_return('title')

  #       put :update, :id => "1"
  #       response.should render_template('edit')
  #     end

  #   end

  # end

  # describe "responding to DELETE destroy" do

  #   it "should destroy the requested datatable" do
  #     Datatable.should_receive(:find,:dataset).with("37").and_return(mock_datatable)

  #     mock_datatable.should_receive(:destroy)
  #     delete :destroy, :id => "37"
  #   end

  #   it "should redirect to the datatables list" do
  #     Datatable.stub!(:find, :dataset).and_return(mock_datatable(:destroy => true))
  #     mock_datatable.should_receive(:dataset).at_least(1).and_return(mock_dataset)
  #     mock_dataset.should_receive(:title).and_return('title')

  #     delete :destroy, :id => "1"
  #     response.should redirect_to(datatables_url)
  #   end

  # end

end
