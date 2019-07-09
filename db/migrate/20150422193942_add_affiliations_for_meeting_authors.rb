class AddAffiliationsForMeetingAuthors < ActiveRecord::Migration[4.2]
  def up
    add_column :meeting_abstracts, :author_affiliations, :text
  end

  def down
    remove_column :meeting_abstracts, :author_affiliations
  end
end
