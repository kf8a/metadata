class AddPdfToProtocols < ActiveRecord::Migration
  def change
    add_column :protocols, :pdf_file_name, :string
    add_column :protocols, :pdf_content_type, :string
    add_column :protocols, :pdf_file_size, :integer
    add_column :protocols, :pdf_updated_at, :datetime
  end
end
