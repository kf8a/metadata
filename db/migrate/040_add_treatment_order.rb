class AddTreatmentOrder < ActiveRecord::Migration[4.2]
  def self.up
    add_column "treatments", "priority", :integer
  end

  def self.down
    remove_column "treatments", "priority"
  end
end
