module PeopleHelper

  def contact_link(email)
    "#{email.gsub(/@/,' at ')}"
  end

  def parenthize(string)
    return string if string.nil?
    return string if string.strip == ""
    return "("+string+")"
  end

  def show_committee(committee,role)
    i = 0
    html = "<li>#{committee}  "
    role.people.each do |person|
      next unless person.affiliations.find_by_role_id(role).title == committee
      if i == 0
        html += link_to "#{person.full_name}", person_path(person)
        i += 1
      else
        html += ", "
        html += link_to "#{person.full_name}", person_path(person)
      end 

    end
    html += "</li>"
    html
  end
end
