class Website < ActiveRecord::Base
  has_many :datasets
  has_many :templates
  has_and_belongs_to_many :protocols
  has_many :study_urls
  
  validates_uniqueness_of :name
  validates_presence_of :name
  
  def layout(controller, action)
    template = self.templates.find_by_controller_and_action(controller, action)
    Liquid::Template.parse(template.layout) if template
  end
end
