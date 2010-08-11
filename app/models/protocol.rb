class Protocol < ActiveRecord::Base
  belongs_to :dataset
  has_and_belongs_to_many :websites
  has_and_belongs_to_many :datatables
  has_many :scribbles
  has_many :people, :through => :scribbles
  has_one :precedent, :class_name => "Protocol", :foreign_key => "precedent_id"
  belongs_to :supercedent, :class_name => "Protocol", :foreign_key => "supercedent_id"

  attr_accessor :website_list
  after_save :update_websites
  
  #TODO update these with proper rails style
  def person_id
    scribbles.collect {|s| s.person_id }
  end
  
  def person_id=(people_ids=[])
    scribbles.delete_all
    people_ids.each do |person|
      self.scribbles.create(:person_id => person)
    end
  end
  
  def update_websites
     websites.delete_all
     selected_websites = website_list.nil? ? [] : website_list.keys.collect{|id| Website.find_by_id(id)}
     selected_websites.each {|website| self.websites << website}
   end
end
