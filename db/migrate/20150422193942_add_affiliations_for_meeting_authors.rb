class AddAffiliationsForMeetingAuthors < ActiveRecord::Migration
  def up
    add_column :meetings, :author_affiliations, :text
  end

  def down
    drop_column :meetings, :author_affiliations, :text
  end
end
