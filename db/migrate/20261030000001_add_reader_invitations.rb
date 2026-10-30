# frozen_string_literal: true

# Admins create accounts for new readers from the grant form (devise_invitable), recording the person's
# name and institution, and optionally what a permission's data is for.
class AddReaderInvitations < ActiveRecord::Migration[8.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :invitation_token
      t.datetime :invitation_created_at
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.integer :invitation_limit
      t.references :invited_by, polymorphic: true
      t.integer :invitations_count, default: 0
      t.index :invitation_token, unique: true
      t.string :first_name
      t.string :last_name
      t.string :institution
    end
    add_column :permissions, :intended_use, :text
  end
end
