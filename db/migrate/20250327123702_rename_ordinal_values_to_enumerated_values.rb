class RenameOrdinalValuesToEnumeratedValues < ActiveRecord::Migration[7.0]
  def change
    rename_table :ordinal_values, :enumerated_values
  end
end