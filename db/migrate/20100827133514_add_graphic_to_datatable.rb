class AddGraphicToDatatable < ActiveRecord::Migration
  def self.up
    add_column :datatables, :summary_graph, :text
  end

  def self.down
    remove_column :datatables, :summary_graph
  end
end
