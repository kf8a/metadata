class AddTermsOfUseUrlToSponsors < ActiveRecord::Migration
  def change
    add_column :sponsors, :terms_of_use_url, :string
  end
end
