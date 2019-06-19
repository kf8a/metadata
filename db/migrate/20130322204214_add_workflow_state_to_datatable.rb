class AddWorkflowStateToDatatable < ActiveRecord::Migration[4.2]
  def change
    add_column :datatables, :workflow_state, :text
  end
end
