require 'rails_helper'

describe PeopleController, type: :controller  do

  context 'not signed in' do

    it 'GET: index' do
      get :index

      expect(response.code).to eq('200')
      expect(response).to render_template('index')
    end

    it 'renders the glbrc index' do
      get :index, params: { requested_subdomain: 'glbrc' }

      expect(response.code).to eq('200')
    end

    it 'GET alphabetical' do
      get :alphabetical

      expect(response.code).to eq '200'
      expect(response).to render_template('alphabetical')
    end

    it 'GET emeritus' do
      get :emeritus

      expect(response.code).to eq '200'
      expect(response).to render_template('emeritus')
    end

    it 'GET new' do
      get :new
      expect(response).to redirect_to('/users/sign_in')
    end

    it 'GET edit' do
      get :edit, params: { id: 1 }

      expect(response).to redirect_to('/users/sign_in')
    end

    it 'DESTROY' do
      delete :destroy, params: { id: 1 }

      expect(response).to redirect_to('/users/sign_in')
    end

    it 'POST: update' do
      put :update, params: { id: '107', person: { 'city' => 'Hickory Corners',
                                                  'postal_code' => '49060',
                                                  'title' => '',
                                                  'lter_role_ids' => ['15'],
                                                  'country' => 'USA',
                                                  'sur_name' => 'Grillo (REU)',
                                                  'url' => '',
                                                  'street_address' => '',
                                                  'given_name' => 'Michael',
                                                  'sub_organization' => 'Kellogg Biological Station',
                                                  'fax' => '',
                                                  'phone' => '',
                                                  'organization' => 'Michigan State University',
                                                  'locale' => 'MI',
                                                  'friendly_name' => 'Mike',
                                                  'middle_name' => '',
                                                  'email' => 'grillom1@msu.edu' } }
      expect(response).to redirect_to('/users/sign_in')
    end

    context 'GET: show' do
      before do
        @person = FactoryBot.create(:person)
      end

      context 'for default' do
        before do
          get :show, params: { id: @person }
        end

        it 'uses the lter template' do
          expect(response).to render_template('lter')
        end
      end

      context 'for subdomain glbrc' do
        before do
          get :show, params: { id: @person, requested_subdomain: 'glbrc' }
        end

        it 'is successful' do
          expect(response.code).to eq('200')
        end

        it 'renders show' do
          expect(response).to render_template('glbrc_show')
        end

        it 'uses the glbrc template' do
          expect(response).to render_template('glbrc')
        end
      end

      context 'for subdomain lter' do
        before do
          get :show, params: { id: @person, requested_subdomain: 'lter' }
        end

        it 'is successful' do
          expect(response.code).to eq('200')
        end

        it 'renders show' do
          expect(response).to render_template('show')
        end

        it 'uses the lter template' do
          expect(response).to render_template('lter')
        end
      end
    end
  end

  # context 'signed in as admin' do
  #
  #   before do
  #     signed_in_as_admin
  #   end
  #
  #   it 'GET new' do
  #     get :new
  #
  #     expect(assigns(:person)).to be_a_new(Person)
  #     expect(response.code).to eq '200'
  #     expect(response).to render_template('new')
  #   end
  #   it 'GET edit' do
  #     get :edit, id: 1
  #     expect(response.code).to eq '200'
  #     expect(response).to render_template('edit')
  #   end
  #
  #   it 'POST create' do
  #     post :create, person: {sur_name: "test create"}
  #     expect(response).to redirect_to("/people/#{assigns(:person).id}")
  #   end
  #
  #   #Trying to update a person with invalid parameters should be tested once any parameters count as invalid.
  #
  #   it 'PUT update' do
  #     put :update, {:id => 107, person: {city: "Hickory Corners", postal_code: "49060", title: "", lter_role_ids: ["15"],
  #       country: "USA", sur_name: "Grillo (REU)", url: "", street_address: "", given_name: "Michael", sub_organization:"Kellogg Biological Station",
  #       fax:"", phone:"", organization:"Michigan State University", locale:"MI", friendly_name:"Mike", middle_name:"", email: "grillom1@msu.edu"}}
  #
  #     expect(response).to redirect_to('/people/107')
  #   end
  #
  #   it 'DESTROY' do
  #     delete :destroy, id: 1
  #     expect(response).to redirect_to('/people')
  #   end
  # end
end
