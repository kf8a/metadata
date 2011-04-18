class AddPdfsToAbstracts < ActiveRecord::Migration
  def self.up
    add_column :meeting_abstracts, :pdf_file_name,    :string
    add_column :meeting_abstracts, :pdf_content_type, :string
    add_column :meeting_abstracts, :pdf_file_size,    :integer
    add_column :meeting_abstracts, :pdf_updated_at,   :datetime
  end

  def self.down
    remove_column :meeting_abstracts, :pdf_updated_at
    remove_column :meeting_abstracts, :pdf_file_size
    remove_column :meeting_abstracts, :pdf_content_type
    remove_column :meeting_abstracts, :pdf_file_name
  end
end
