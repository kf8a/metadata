require File.expand_path('../../test_helper', __FILE__)

class ProtocolTest < ActiveSupport::TestCase
  should have_and_belong_to_many :websites
  should have_and_belong_to_many :datatables

  context 'a protocol' do
    setup do
      @website = Website.find_by_name('lter')
      @website2 = Website.find_by_name('glbrc')
      @protocol = FactoryBot.create(:protocol)
    end

    should 'save websites' do
      @protocol.websites << @website
      assert @protocol.save

      assert @protocol.websites.include?(@website)
    end

    should 'save multiple websites' do
      @protocol.websites << [@website, @website2]
      assert @protocol.save

      assert @protocol.websites.include?(@website)
      assert @protocol.websites.include?(@website2)
    end
  end

  context 'deprecating a protocol' do
    setup do
      @protocol = FactoryBot.create(:protocol, version_tag: 4)
      @new_protocol = FactoryBot.create(:protocol)
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

# == Schema Information
#
# Table name: protocols
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  title          :string(255)
#  version_tag    :integer
#  in_use_from    :date
#  in_use_to      :date
#  description    :text
#  abstract       :text
#  body           :text
#  person_id      :integer
#  created_on     :date
#  updated_on     :date
#  change_summary :text
#  dataset_id     :integer
#  active         :boolean         default(TRUE)
#  deprecates     :integer
#
