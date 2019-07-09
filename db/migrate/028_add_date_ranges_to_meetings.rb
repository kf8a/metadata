class AddDateRangesToMeetings < ActiveRecord::Migration[4.2]
  def self.up
    add_column "meetings", "date_to", :date
  end

  def self.down
    remove_column "meetings", "date_to"
  end
end
