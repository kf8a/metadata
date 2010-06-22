require 'test_helper'

class DatafileControllerTest < ActionController::TestCase
  
  context 'get requests' do
    setup do
      get :index
    end
   
    should assign_to :datafiles
  end
  
  context 'uploading new files' do
    setup do
      put :datafile
    end
  end
end
