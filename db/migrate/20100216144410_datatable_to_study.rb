class DatatableToStudy < ActiveRecord::Migration[4.2]
  def self.up
    add_column :datatables, :study_id, :integer
    
    Datatable.reset_column_information
    Datatable.all.each do |table| 
      next if table.dataset.studies.empty?
      table.update_attribute(:study_id,table.dataset.studies.first.id)
      say "#{table.name} updated!", true
    end
    
  end

  def self.down
    remove_column :datatables, :study_id
  end
end
