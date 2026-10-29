# frozen_string_literal: true

# Foreign keys for permissions and permission requests. Deleting a user or a datatable removes their
# permissions and requests. Deleting the admin who granted a permission keeps the permission (the user
# keeps access) and only forgets who granted it. Rows that already point at a deleted user or datatable
# are removed first; the original permissions are kept in permissions_legacy.
class AddPermissionForeignKeys < ActiveRecord::Migration[8.1]
  def up
    %w[permissions permission_requests].each do |table|
      execute <<~SQL.squish
        DELETE FROM #{table} t
        WHERE NOT EXISTS (SELECT 1 FROM users u WHERE u.id = t.user_id)
           OR NOT EXISTS (SELECT 1 FROM datatables d WHERE d.id = t.datatable_id)
      SQL
      change_column_null table, :user_id, false
      change_column_null table, :datatable_id, false
      add_foreign_key table, :users, on_delete: :cascade
      add_foreign_key table, :datatables, on_delete: :cascade
    end

    execute <<~SQL.squish
      UPDATE permissions p SET owner_id = NULL
      WHERE owner_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM users u WHERE u.id = p.owner_id)
    SQL
    add_foreign_key :permissions, :users, column: :owner_id, on_delete: :nullify
  end

  def down
    remove_foreign_key :permissions, column: :owner_id
    %w[permissions permission_requests].each do |table|
      remove_foreign_key table, :datatables
      remove_foreign_key table, :users
      change_column_null table, :datatable_id, true
      change_column_null table, :user_id, true
    end
  end
end
