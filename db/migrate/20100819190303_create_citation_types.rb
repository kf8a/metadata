class CreateCitationTypes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :citation_types do |t|
      t.string :abbreviation
      t.string :name

      t.timestamps
    end
    CitationType.reset_column_information
    list = [
      ["ABST", "Abstract"], 
      ["ADVS", "Audiovisual material"], 
      ["ART", "Art Work"], 
      ["BOOK", "Whole book"], 
      ["CASE", "Case"], 
      ["CHAP", "Book chapter"], 
      ["COMP", "Computer program"], 
      ["CONF", "Conference proceeding"], 
      ["CTLG", "Catalog"], 
      ["DATA", "Data file"], 
      ["ELEC", "Electronic Citation"],
      ["GEN", "Generic"], 
      ["HEAR", "Hearing"], 
      ["ICOMM", "Internet Communication"], 
      ["INPR", "In Press"], 
      ["JFULL", "Journal (full)"], 
      ["JOUR", "Journal"],
      ["MAP", "Map"], 
      ["MGZN", "Magazine article"], 
      ["MPCT", "Motion picture"], 
      ["MUSIC", "Music score"], 
      ["NEWS", "Newspaper"], 
      ["PAMP", "Pamphlet"], 
      ["PAT", "Patent"], 
      ["PCOMM", "Personal communication"], 
      ["RPRT", "Report"], 
      ["SER", "Serial publication"], 
      ["SLIDE", "Slide"], 
      ["SOUND", "Sound recording"], 
      ["STAT", "Statute"], 
      ["THES", "Thesis/Dissertation"], 
      ["UNPB", "Unpublished work"], 
      ["VIDEO", "Video recording"]
    ]
    list.each do |item|
      CitationType.create! :abbreviation=>item[0], :name=>item[1]
    end

  end

  def self.down
    drop_table :citation_types
  end
end
