class CreateStudyUrls < ActiveRecord::Migration
  def self.up
    create_table :study_urls do |t|
      t.integer :website_id
      t.integer :study_id
      t.string  :url
      
    end
    
    StudyUrl.reset_column_information
     website = Website.find_by_name('lter')
     Study.all.each do |study|
       url = StudyUrl.create :study => study, :url => study.url, :website => website
       study.study_urls << [url]
       study.save
     end
     
#     remove_column :studies, :url
  end

  def self.down
#    add_column :studies, :url, :string
    drop_table :study_urls
  end
end
