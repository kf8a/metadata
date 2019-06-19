class AddAnnotationToCitation < ActiveRecord::Migration[4.2]
  def change
    add_column :citations, :annotation, :string
  end
end
