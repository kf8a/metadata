class ExtractExcerptLimit < ActiveRecord::Migration[4.2]
  def self.up
    add_column :datatables, :excerpt_limit, :integer

    Datatable.reset_column_information
    Datatable.all.each do | table |
      table.excerpt_limit = 50
      table.save
    end
  end

  def self.down
    remove_column :datatables, :excerpt_limit
  end
end
