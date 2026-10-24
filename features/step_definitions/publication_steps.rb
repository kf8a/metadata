# frozen_string_literal: true

Given(/^the journal articles publication type exists$/) do
  pub = begin
    PublicationType.find(1)
  rescue StandardError
    nil
  end
  unless pub
    pub = PublicationType.new
    pub.id = 1
    pub.name = "Journal_Articles"
    pub.save
  end
end
