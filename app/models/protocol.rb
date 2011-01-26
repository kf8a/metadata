#TODO add an updated_by attribute to track who changed the protocol
#TODO save old protocols in an old_protocol table just in case there is a problem with vestal_versions
class Protocol < ActiveRecord::Base
  belongs_to :dataset
  has_and_belongs_to_many :websites
  has_and_belongs_to_many :datatables
  has_many :scribbles
  has_many :people, :through => :scribbles
  has_one :precedent, :class_name => "Protocol", :foreign_key => "precedent_id"
  belongs_to :supercedent, :class_name => "Protocol", :foreign_key => "supercedent_id"

  versioned :dependent => :tracking

  attr_accessor :website_list
  after_save :update_websites

  def archive
    archived = true
  end
  
  #TODO update these with proper rails style
  def update_websites
     websites.delete_all
     selected_websites = website_list.nil? ? [] : website_list.keys.collect{|id| Website.find_by_id(id)}
     selected_websites.each {|website| self.websites << website}
   end
end
