class Website < ActiveRecord::Base
  has_many :datatables
  has_many :templates
  
  def layout(controller, action)
    template = templates.find(:first, :conditions => ['controller = ? and action = ?', controller, action])
    Liquid::Template.parse(template.layout) if template
  end
end