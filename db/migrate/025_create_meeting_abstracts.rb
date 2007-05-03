class CreateMeetingAbstracts < ActiveRecord::Migration
  def self.up
    create_table :meeting_abstracts do |t|
      t.column :title, :string
      t.column :authors, :string
      t.column :abstract, :text
      t.column :meeting_id, :integer
    end
  end

  def self.down
    drop_table :meeting_abstracts
  end
end
