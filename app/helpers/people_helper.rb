module PeopleHelper

  def contact_link(email)
    "<span id='email'>#{email.gsub(/@/,' at ')}</span>"
  end

  def parenthize(string)
    return string if string.nil?
    return string if string.strip == ""
    return "("+string+")"
  end

  def show_committee(committee,role)
    html = "<li>#{committee}  "
    role.people.each_with_index do |person,i|
      next unless person.affiliations.find_by_role_id(role).title == committee
      if i == 0
        html += link_to "#{person.full_name}", person_path(person)
      else
        html += ", "
        html += link_to "#{person.full_name}", person_path(person)
      end 

    end
    html += "</li>"
    html
  end
end
