require File.expand_path('../../test_helper',__FILE__) 

class PublicationTest < ActiveSupport::TestCase
  
  context 'finding publications by words' do
    setup do
      @pub = Factory.create(:publication)
      @other_pub = Factory.create(:publication, :citation => 'bohms', :abstract => 'nothing really')
    end
    
    should 'return one record if called with word = bogus' do
      assert Publication.find_by_word('bogus').size == 1
    end
    
    should 'be case insensitive' do
      assert Publication.find_by_word('BOGUS')[0] == @pub
    end

    should 'return the @pub record if called with word = bogus' do
      assert Publication.find_by_word('bogus')[0] == @pub
    end
    
    should  'return other_pub if called with word = bohms ' do
      assert Publication.find_by_word('bohms')[0] == @other_pub
    end
    
    should 'not return anything if called with word = bogus2' do 
      assert Publication.find_by_word('bogus2').empty?
    end
    
    should 'be ordered by year'
    
  end

end
