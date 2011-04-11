require File.expand_path('../../test_helper',__FILE__)

class ProtocolTest < ActiveSupport::TestCase
  should have_and_belong_to_many :websites
  should have_and_belong_to_many :datatables

  context 'a protocol' do
    setup do
      @website = Website.find_by_name('lter')
      @website2 = Website.find_by_name('glbrc')
      @protocol = Factory.create(:protocol)
    end

    should 'save websites' do
      @protocol.websites << @website
      assert @protocol.save

      assert @protocol.websites.include?(@website)
    end

    should 'save multiple websites' do
       @protocol.websites << [@website, @website2 ]
        assert @protocol.save

        assert @protocol.websites.include?(@website)
        assert @protocol.websites.include?(@website2)
    end
  end

  context 'deprecating a protocol' do
    setup do
      @protocol = Factory.create(:protocol, :version_tag => 4)
      @new_protocol = Factory.create(:protocol)
      @new_protocol.deprecate!(@protocol)
      @protocol.reload
    end

    should 'increment the protocol number of the new protocol' do
      assert_equal @protocol.version_tag + 1, @new_protocol.version_tag
    end

    should 'connect the new protocol to the old protocol' do
      assert_equal @protocol.id, @new_protocol.deprecates
    end

    should 'deactivate the old protocol' do
      assert_equal false, @protocol.active?
      assert_equal true, @new_protocol.active?
    end

    should 'enable the report of the newer version by the old version' do
      newer = @protocol.replaced_by
      assert_equal @new_protocol.id, newer.id
    end
  end
end
