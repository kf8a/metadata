require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Protocol do
  describe 'eml importation' do
    before(:each) do
      @protocol = FactoryBot.create(:protocol)
    end

    it 'should import protocols' do
      eml_content = @protocol.to_eml
      eml_element = Nokogiri::XML(eml_content).css('methodStep protocol').first
      imported_protocol = Protocol.from_eml(eml_element)
      expect(imported_protocol).to eq @protocol
    end

    it 'should import new protocols' do
      @protocol.title = 'A sweet title'
      eml_content = @protocol.to_eml
      protocol_id = @protocol.id
      @protocol.destroy
      assert !Protocol.exists?(protocol_id)
      eml_element = Nokogiri::XML(eml_content).css('methodStep protocol').first
      imported_protocol = Protocol.from_eml(eml_element)
      expect(imported_protocol.title).to eq 'A sweet title'
      expect(imported_protocol).to be_valid
      assert imported_protocol.save
    end
  end
end
