class AddDateRangesToMeetings < ActiveRecord::Migration
  def self.up
    add_column "meetings", "date_to", :date
  end

  def self.down
    remove_column "meetings", "date_to"
  end
end
