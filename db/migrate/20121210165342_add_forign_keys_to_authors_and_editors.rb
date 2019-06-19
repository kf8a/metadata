class AddForignKeysToAuthorsAndEditors < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key(:authors,:citations)
    add_foreign_key(:editors, :citations)
  end
end
