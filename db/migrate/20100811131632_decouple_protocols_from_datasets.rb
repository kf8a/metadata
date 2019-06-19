class DecoupleProtocolsFromDatasets < ActiveRecord::Migration[4.2]
  def self.up
    create_table :protocols_websites, :id => false, :force => true do |t|
      t.integer :protocol_id
      t.integer :website_id
    end
    create_table :datatables_protocols, :id => false, :force => true do |t|
      t.integer :datatable_id
      t.integer :protocol_id
    end
  end

  def self.down
    drop_table :datatables_protocols
    drop_table :protocols_websites
  end
end
