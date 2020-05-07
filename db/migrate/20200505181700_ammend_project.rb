class AmmendProject < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :funder_name, :string
    add_column :projects, :funder_identifier, :string
    add_column :projects, :award_number, :string
    add_column :projects, :award_url, :string
  end
end
