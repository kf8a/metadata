# frozen_string_literal: true

# The identity provider groups seen at a user's most recent GLBRC sign-in
class AddLastGlbrcGroupsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :last_glbrc_groups, :string, array: true, default: [], null: false
  end
end
