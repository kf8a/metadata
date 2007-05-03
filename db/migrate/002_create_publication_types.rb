class CreatePublicationTypes < ActiveRecord::Migration
  def self.up
    create_table :publication_types do |t|
      t.column "name", :string
    end
    PublicationType.reset_column_information
    PublicationType.new(:name => 'journal').save
    PublicationType.new(:name => 'thesis').save
    PublicationType.new(:name => 'book').save
  end

  def self.down
    drop_table :publication_types
  end
end
