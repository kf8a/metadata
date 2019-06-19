class AddSuffixToAuthors < ActiveRecord::Migration[4.2]
def self.up
    add_column :authors, :suffix, :string
  end

  def self.down
    remove_column :authors, :suffix
  end
end
