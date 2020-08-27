# frozen_string_literal: true

# Helpers for the people page
module PeopleHelper
  def contact_link(email)
    email.to_s.gsub(/@/, ' at ')
  end

  def parenthize(string)
    return string if string.nil?
    return string if string.strip == ''

    "(#{string})"
  end

  def committee_affiliations(committee, role)
    affiliations = role.people.collect do |x|
      x.affiliations
       .where(role_id: role)
       .where(title: committee)
       .where('left_on is null')
    end
    affiliations.flatten.uniq # .sort {|a,b| a.seniority <=> b.seniority }
  end

  def show_committee(committee, role)
    first_one = true
    html = "<li>#{committee}:  "
    committee_people = committee_affiliations(committee, role).collect(&:person)
    committee_people.each do |person|
      if first_one
        first_one = false
      else
        html += ', '
      end
      html += link_to person.full_name.to_s, person_path(person)
    end
    "#{html}</li>"
  end
end
