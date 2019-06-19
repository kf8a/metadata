class CreateMeetings < ActiveRecord::Migration[4.2]
  def self.up
    create_table :meetings do |t|
      t.column :date, :date
      t.column :title, :string
      t.column :announcement, :text
    end
  end

  def self.down
    drop_table :meetings
  end
end
