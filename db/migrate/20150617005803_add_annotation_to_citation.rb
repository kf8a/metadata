class AddAnnotationToCitation < ActiveRecord::Migration
  def change
    add_column :citations, :annotation, :text
  end
end
