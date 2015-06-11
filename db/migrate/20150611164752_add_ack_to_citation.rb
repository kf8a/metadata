class AddAckToCitation < ActiveRecord::Migration
  def change
    add_column :citations, :has_lter_acknowledgement, :boolean
  end
end
