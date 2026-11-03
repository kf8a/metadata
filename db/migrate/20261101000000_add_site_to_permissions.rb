# frozen_string_literal: true

# The site (lter or glbrc) a permission was granted from, so its emails, including the reminder sent
# later by a job, link back to that site
class AddSiteToPermissions < ActiveRecord::Migration[8.1]
  def change
    add_column :permissions, :site, :string
  end
end
