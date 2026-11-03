# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe DatatablesController, type: :controller  do
  def mock_datatable(_stubs = {})
    @mock_datatable ||= double(Datatable).as_null_object
    allow(@mock_datatable).to receive(:dataset).at_least(1).and_return(mock_dataset)
    allow(@mock_datatable).to receive(:is_sql).and_return(true)
    allow(@mock_datatable).to receive(:is_restricted).and_return(false)
    allow(@mock_datatable).to receive(:object).and_return('select * from datatables')
    allow(@mock_datatable).to receive(:study)
    allow(@mock_dataset).to receive(:title).and_return('title')
    @mock_datatable
  end

  def mock_dataset(_stubs = {})
    @mock_dataset ||= double(Dataset).as_null_object
  end

  before do
    FactoryBot.create(:website, name: 'lter')
    @user = FactoryBot.create(:admin_user)
    sign_in @user
  end

  describe 'responding to GET index' do
    it 'should return an empty array' do
      get :index
      expect(assigns[:datatables]).to eq []
    end
  end

  describe 'GET show as csv for a members-only datatable' do
    it 'is forbidden when not signed in' do
      sign_out @user
      datatable = FactoryBot.create(:protected_datatable)

      get :show, params: { id: datatable.id }, format: :csv

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET show as csv for a public datatable' do
    it 'streams the csv when not signed in' do
      sign_out @user
      website = Website.find_by(name: 'lter')
      website.update!(url: 'lter.kbs.msu.edu')
      datatable = FactoryBot.create(:public_datatable, dataset: FactoryBot.create(:dataset, website: website),
                                                       object: "select '2020-01-01'::date as sample_date")

      get :show, params: { id: datatable.id }, format: :csv

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(datatable.csv_headers + "2020-01-01\n")
    end
  end

  describe 'GET show as csv for an admin' do
    it 'streams every row when the stored query ends in a semicolon' do
      website = Website.find_by(name: 'lter')
      website.update!(url: 'lter.kbs.msu.edu')
      datatable = FactoryBot.create(:datatable, dataset: FactoryBot.create(:dataset, website: website),
                                                number_of_released_records: 1,
                                                object: 'select g as n from generate_series(1, 3) g order by g desc;')

      get :show, params: { id: datatable.id }, format: :csv

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(datatable.csv_headers + "3\n2\n1\n")
    end
  end

  describe 'GET show as csv for a datatable that is not SQL' do
    let(:datatable) do
      website = Website.find_by(name: 'lter')
      website.update!(url: 'lter.kbs.msu.edu')
      # The stored text is not a query (a name, or blank), as for data hosted elsewhere
      FactoryBot.create(:public_datatable, dataset: FactoryBot.create(:dataset, website: website),
                                           is_sql: false, object: 'KBS001-001', data_url: 'https://example.org/data')
    end

    it 'is not found for a visitor, without running the stored text as a query' do
      sign_out @user
      expect(Datatable).not_to receive(:stream_query_rows)

      get :show, params: { id: datatable.id }, format: :csv

      expect(response).to have_http_status(:not_found)
      expect(response.body).to be_empty
    end

    it 'is not found for an admin either' do
      expect(Datatable).not_to receive(:stream_query_rows)

      get :show, params: { id: datatable.id }, format: :csv

      expect(response).to have_http_status(:not_found)
    end

    it 'still shows the page, which links to the data elsewhere' do
      get :show, params: { id: datatable.id }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'responding to publish request' do
    it 'should publish' do
      website = Website.find_by(name: 'lter')
      website.update!(url: 'lter.kbs.msu.edu')
      dataset = FactoryBot.create(:dataset, website: website)
      datatable = FactoryBot.create(:datatable, dataset: dataset,
                                                object: "select '2020-01-01'::date as sample_date")

      put :publish, params: { id: datatable.id }

      expect(response).to redirect_to(datatable_path(datatable))
      expect(response).to have_http_status(:see_other)
      expect(datatable.reload.csv_file).to be_attached
      expect(datatable.csv_file.download).to eq(datatable.csv_headers + "2020-01-01\n")

      put :retract, params: { id: datatable.id }

      expect(response).to redirect_to(datatable_path(datatable))
      expect(datatable.reload.csv_file).not_to be_attached
    end
  end

  describe 'responding to GET show' do
    it 'should expose the requested datatable as @datatable' do
      allow(Datatable).to receive(:find).with('37').at_least(1).and_return(mock_datatable)
      get :show, params: { id: '37' }
      expect(assigns[:datatable]).to eq(mock_datatable)
    end

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

    describe 'responding to GET new' do
      it 'should expose a new datatable as @datatable' do
        allow(Datatable).to receive(:new).and_return(mock_datatable)
        get :new
        expect(assigns[:datatable]).to eq(mock_datatable)
      end
    end

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
  end

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
