class CreateEmlDocs < ActiveRecord::Migration
  def self.up
    create_table :eml_docs do |t|
    end
  end

  def self.down
    drop_table :eml_docs
  end
end
