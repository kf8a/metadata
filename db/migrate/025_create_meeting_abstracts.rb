class CreateMeetingAbstracts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :meeting_abstracts do |t|
      t.column :title, :text
      t.column :authors, :text
      t.column :abstract, :text
      t.column :meeting_id, :integer
    end
  end

  def self.down
    drop_table :meeting_abstracts
  end
end
