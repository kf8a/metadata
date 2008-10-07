class Protocol < ActiveRecord::Base
  belongs_to :dataset
  has_many :scribbles
  has_many :people, :through => :scribbles
  
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
