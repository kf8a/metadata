module PeopleHelper
  
  def contact_link(email)
    "<span id='email'>#{email.gsub(/@/,' at ')}</span>"
  end
  
  
  def show_committee(committee_name, role)
    html = committee_name
    role.people.each do |person|
     # next unless person.affiliations.find_by_role_id(role).title == committee_name
      html = html  + "<% link_to #{person.full_name}, person_path(person)&nbsp;%>"
    end
    html
  end
  
  
end
