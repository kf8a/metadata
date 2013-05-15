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
    first_one = true
    html = "<li>#{committee}  "
    committee_affiliations = role.people.collect {|x| x.affiliations.where(:role_id => role).where(:title => committee)}.flatten.uniq
    committee_people = committee_affiliations.collect {|x| x.person }
    committee_people.each do |person|
      if first_one
        html += link_to "#{person.full_name}", person_path(person)
        first_one = false
      else
        html += ", "
        html += link_to "#{person.full_name}", person_path(person)
      end 

    end
    html += "</li>"
    html
  end
end
