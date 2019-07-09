class CreateUsers < ActiveRecord::Migration[4.2]
  def self.up
    create_table :users do |t|
      t.column :open_id, :string
      t.column :email, :string
      t.column :role_id, :int
    end
  end

  def self.down
    drop_table :users
  end
end
