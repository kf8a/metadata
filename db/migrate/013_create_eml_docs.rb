class CreateEmlDocs < ActiveRecord::Migration[4.2]
  def self.up
    create_table :eml_docs do |t|
    end
  end

  def self.down
    drop_table :eml_docs
  end
end
