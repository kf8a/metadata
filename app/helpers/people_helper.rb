module PeopleHelper
  
  def contact_link(email)
    "<span id='email'>#{email.gsub(/@/,' at ')}</span>"
  end
end
