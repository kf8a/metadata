class CreatePeople < ActiveRecord::Migration[4.2]
  def self.up
    create_table :people do |t|
      t.column :person, :string
      t.column :sur_name, :string
      t.column :given_name, :string
      t.column :middle_name, :string
      t.column :friendly_name, :string
      t.column :title, :string
      t.column :sub_organization, :string
      t.column :organization, :string
      t.column :street_address, :string
      t.column :city, :string
      t.column :locale, :string
      t.column :country, :string
      t.column :postal_code, :string
      t.column :phone, :string
      t.column :fax, :string
      t.column :email, :string
      t.column :url, :string
      t.column :deceased, :boolean
      t.column :open_id, :string
    end
  end

  def self.down
    drop_table :people
  end
end
