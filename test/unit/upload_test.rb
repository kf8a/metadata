require File.expand_path('../../test_helper',__FILE__) 

class UploadTest < ActiveSupport::TestCase
  context 'saving' do 
    setup do
      @upload = Factory.create(:upload)
      @good_data = @upload
    end
    
    should "save good data upload" do
      assert @good_data.save
    end
    
    should "have a title element" do
      assert @upload.respond_to?(:title)
    end
    
    should "have an abstract element" do
      assert @upload.respond_to?(:abstract)
    end
    
    should "have an owners element" do
      assert @upload.respond_to?(:owners)
    end
    
    should "have a file element" do
      assert @upload.respond_to?(:file)
    end
  end
end
