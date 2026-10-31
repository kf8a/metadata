# frozen_string_literal: true

# Admins create accounts for new readers from the grant form (devise_invitable), recording the person's
# name and institution, and optionally what a permission's data is for. devise_invitable 3 keeps the
# invitations in their own table, pointing at the placeholder account it creates.
class AddReaderInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :devise_invitations do |t|
      t.string :invitation_token
      t.datetime :invitation_created_at
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.datetime :superseded_at
      t.string :superseded_reason
      t.datetime :revoked_at
      t.datetime :resource_created_at
      t.json :invite_key, null: false, default: {}
      t.string :invite_key_digest, null: false
      t.references :invitable, polymorphic: true
      t.references :invited_by, polymorphic: true
      t.timestamps
      t.index :invitation_token, unique: true
      t.index %i[invitable_type invite_key_digest], name: 'index_devise_invitations_on_type_and_invite_key'
    end

    change_table :users, bulk: true do |t|
      t.string :first_name
      t.string :last_name
      t.string :institution
    end
    add_column :permissions, :intended_use, :text
  end
end
