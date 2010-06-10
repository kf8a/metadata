class Protocol < ActiveRecord::Base
  belongs_to :dataset
  has_many :scribbles
  has_many :people, :through => :scribbles
  has_one :precedent, :class_name => "Protocol", :foreign_key => "precedent_id"
  belongs_to :supercedent, :class_name => "Protocol", :foreign_key => "supercedent_id"
  
  has_and_belongs_to_many :sponsors
  
  named_scope :glbrc, {
    :joins => 'join protocols_sponsors on protocols_sponsors.protocol_id = protocols.id join sponsors on sponsors.id = protocols_sponsors.sponsor_id',
    :conditions => "sponsors.name = 'GLBRC' and active is true",
    :order => "protocols.title"
  }
   
  #TODO update these with proper rails style
  def person_id
    scribbles.collect {|s| s.person_id }
  end
  
  def person_id=(people_ids=[])
    scribbles.each {|scribble| scribble.destroy}
    people_ids.each do |person|
      self.scribbles.create(:person_id => person)
    end
  end
end
