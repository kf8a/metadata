# Methods added to this helper will be available to all templates in the application.
require 'redcloth'

module ApplicationHelper
  def textilize(text)
    RedCloth.new(text).to_html
  end 
  
  def lter_roles
    Role.find(:all,  :conditions => ['role_type_id = ?', RoleType.find_by_name('lter')])
  end
  
end
