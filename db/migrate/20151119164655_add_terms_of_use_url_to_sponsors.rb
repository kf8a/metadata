class AddTermsOfUseUrlToSponsors < ActiveRecord::Migration[4.2]
  def change
    add_column :sponsors, :terms_of_use_url, :string
  end
end
