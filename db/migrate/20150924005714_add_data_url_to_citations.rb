class AddDataUrlToCitations < ActiveRecord::Migration
  def change
    add_column :citations, :data_url, :string
  end
end
