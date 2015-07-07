require 'spec_helper'

describe DatasetsController do
  render_views

  # describe 'POST :create with an eml_link' do
  #   before(:each) do
  #     post :create, :eml_link => 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-gce.113.13'
  #   end

  #   it { should redirect_to(dataset_path(assigns(:dataset))) }
  # end

  # describe 'POST :create with a bad eml_link' do
  #   before(:each) do
  #     post :create, :eml_link => 'http://google.com'
  #   end

  #   it { should render_template 'new' }
  #   it { should set_the_flash.to("Eml import had errors: The document has no document element.")}
  # end
end
