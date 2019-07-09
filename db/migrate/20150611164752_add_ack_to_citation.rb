class AddAckToCitation < ActiveRecord::Migration[4.2]
  def change
    add_column :citations, :has_lter_acknowledgement, :boolean
  end
end
