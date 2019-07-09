class AddDataUrlToCitations < ActiveRecord::Migration[4.2]
  def change
    add_column :citations, :data_url, :string
  end
end
