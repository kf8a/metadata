module PeopleHelper
  
  def contact_link(email)
    "<span id='email'>#{email.gsub(/@/,' at ')}</span>"
  end
  
  def lter_roles
    Role.find(:all,  :conditions => ['role_type_id = ?', RoleType.find_by_name('lter')])
  end
end
