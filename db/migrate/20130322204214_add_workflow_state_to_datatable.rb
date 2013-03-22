class AddWorkflowStateToDatatable < ActiveRecord::Migration
  def change
    add_column :datatables, :workflow_state, :text
  end
end
