class AddForignKeysToAuthorsAndEditors < ActiveRecord::Migration
  def change
    add_foreign_key(:authors,:citations)
    add_foreign_key(:editors, :citations)
  end
end
