class AddOrdinalValues < ActiveRecord::Migration[7.2]
  def change
    create_table :ordinal_values do |t|
      t.references :variate, null: false
      t.string :code, null: false
      t.string :description, null: false
      t.timestamps
    end
  end
end
