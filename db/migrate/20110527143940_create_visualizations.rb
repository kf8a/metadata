class CreateVisualizations < ActiveRecord::Migration[4.2]
  def self.up
    create_table :visualizations do |t|
      t.integer      :datatable_id
      t.string       :title
      t.text         :body
      t.text         :query
      t.string       :graph_type
      t.timestamps
    end
  end

  def self.down
    drop_table :visualizations
  end
end
