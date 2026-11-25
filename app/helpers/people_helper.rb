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

  # <li>Committee: Name, Name</li>, each name linking to the person's page. Built as safe HTML, so the names
  # are escaped and the view needs no raw.
  def show_committee(committee, role)
    people = committee_affiliations(committee, role).collect(&:person)
    links = people.collect { |person| link_to(person.full_name.to_s, person_path(person)) }
    tag.li(safe_join(["#{committee}:  ", safe_join(links, ', ')]))
  end
end
