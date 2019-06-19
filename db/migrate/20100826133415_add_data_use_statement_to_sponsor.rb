class AddDataUseStatementToSponsor < ActiveRecord::Migration[4.2]
  def self.up
    add_column :sponsors, :data_use_statement, :text
  end

  def self.down
    remove_column :sponsors, :data_use_statement
  end
end
