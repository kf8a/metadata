class AddSuffixToAuthors < ActiveRecord::Migration
def self.up
    add_column :authors, :suffix, :string
  end

  def self.down
    remove_column :authors, :suffix
  end
end
