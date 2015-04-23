class AddMeetingAbstractType < ActiveRecord::Migration
  def up
    add_column :meeting_abstracts, :meeting_abstract_type_id, :integer
    create_table :meeting_abstract_types do |t|
      t.text :name
      t.integer :order
      t.timestamps
    end
  end

  def down
    remove_column :meeting_abstracts, :meeting_abstract_type_id
    drop_table :meeting_abstract_types
  end
end
