class AddSuffixToEditors < ActiveRecord::Migration[4.2]
  def self.up
    add_column :editors, :suffix, :string
  end

  def self.down
    remove_column :editors, :suffix
  end
end
