require 'spec_helper'

describe PeopleController, type: :controller  do

  context 'not signed in' do

    it 'GET: index' do
      get :index

      expect(response.code).to eq('200')
    end

    it 'renders the glbrc index' do
      get :index, :requested_subdomain => 'glbrc'

      expect(response.code).to eq('200')
    end


    context 'GET: show' do
      before do 
        @person = FactoryGirl.create(:person)
      end

      context 'for default' do
        before do
          get :show, :id => @person
        end

        it 'uses the lter template' do
          expect(response).to render_template('lter')
        end
      end


      context "for subdomain glbrc" do
        before do
          get :show, :id => @person, :requested_subdomain => 'glbrc'
        end

        it 'is successful' do
          expect(response.code).to eq("200")
        end

        it 'renders show' do
          expect(response).to render_template("show")
        end

        it 'uses the glbrc template' do
          expect(response).to render_template('glbrc')
        end
      end

      context 'for subdomain lter' do
        before do
          get :show, :id => @person, :requested_subdomain => 'lter'
        end

        it 'is successful' do
          expect(response.code).to eq("200")
        end

        it 'renders show' do
          expect(response).to render_template("show")
        end

        it 'uses the lter template' do
          expect(response).to render_template('lter')
        end
      end
    end

  end
end
