class CreateScribbles < ActiveRecord::Migration
  def self.up
    create_table :scribbles do |t|
      t.integer :person_id
      t.integer :protocol_id
      t.integer :order
    end
    Scribble.reset_column_information
    protocols = Protocol.find(:all)
    protocols.each do |protocol|
      Scribble.create({:protocol_id => protocol.id, 
          :person_id => protocol.person_id, :order => 1})
    end
  end

  def self.down
    drop_table :scribbles
  end
end
