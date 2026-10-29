# frozen_string_literal: true

# Permissions become grants made by an admin: one row per user and datatable, with an optional expiry
# date. Owners used to approve or deny each user separately, and a user had access only once every
# current owner had approved. Only the pairs that have access under that rule today are kept, so nobody
# gains or loses access. All old rows, denials included, are kept in permissions_legacy.
class SimplifyPermissions < ActiveRecord::Migration[8.1]
  def up
    execute 'CREATE TABLE permissions_legacy AS TABLE permissions'
    add_column :permissions, :expires_on, :date

    execute <<~SQL.squish
      DELETE FROM permissions WHERE id NOT IN (
        SELECT min(p.id)
        FROM permissions p
        JOIN ownerships o ON o.datatable_id = p.datatable_id AND o.user_id = p.owner_id
        WHERE p.decision = 'approved'
        GROUP BY p.user_id, p.datatable_id
        HAVING count(DISTINCT p.owner_id) =
               (SELECT count(*) FROM ownerships o2 WHERE o2.datatable_id = p.datatable_id)
      )
    SQL
    add_index :permissions, %i[user_id datatable_id], unique: true
  end

  def down
    remove_index :permissions, %i[user_id datatable_id]
    remove_column :permissions, :expires_on
    execute 'DELETE FROM permissions'
    execute 'INSERT INTO permissions SELECT * FROM permissions_legacy'
    drop_table :permissions_legacy
  end
end
