# Methods added to this helper will be available to all templates in the application.
require 'redcloth'

module ApplicationHelper
  def textilize(text)
    text ? RedCloth.new(text).to_html : '' 
  end 
  
  # use to strip out html tags when using truncate
  def strip_html_tags(string = '')
    string.gsub(/<\/?[^>]*>/,  "")
  end
  
  def lter_roles
    Role.find_all_by_role_type_id(RoleType.find_by_name('lter'))
  end
  
  def render_study(options)
    study = Study.find(:first, :conditions => options)
    
    if study
      render :partial => 'study',  :locals => {:study => study}
    end
  end
  
  def admin?
    current_user.try(:role) == 'admin'
  end

  def get_liquid_template(domain, controller, page)
    website = Website.find_by_name(domain)
    website = Website.find(:first) unless website
    plate = nil
    plate = website.layout(controller, page) if website
  end

end
