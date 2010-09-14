class CreateCitations < ActiveRecord::Migration
  def self.up
    create_table :citations do |t|
      t.text :title
      t.text :abstract
      t.date :pub_date
      t.integer :pub_year
      t.integer :citation_type_id
      t.text :address
      t.text :notes
      t.string :publication
      t.integer :start_page_number
      t.integer :ending_page_number
      t.text :periodical_full_name
      t.string :periodical_abbreviation
      t.string :volume
      t.string :issue
      t.string :city
      t.string :publisher
      t.string :secondary_title
      t.string :series_title
      t.string :isbn
      t.string :doi
      t.string :pdf
      t.text :full_text
      t.string :url
      t.integer :website_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :citations
  end
end
