class Website < ActiveRecord::Base
  has_many :datasets
  has_many :templates
  has_and_belongs_to_many :protocols
  has_many :study_urls
  
  validates_uniqueness_of :name
  validates_presence_of :name
  
  def layout(controller, action)
    template = templates.find(:first, :conditions => ['controller = ? and action = ?', controller, action])
    Liquid::Template.parse(template.layout) if template
  end
end
