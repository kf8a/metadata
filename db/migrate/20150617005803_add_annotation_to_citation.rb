class AddAnnotationToCitation < ActiveRecord::Migration
  def change
    add_column :citations, :annotation, :string
  end
end
