Given /^the journal articles publication type exists$/ do
  pub = PublicationType.find(1) rescue nil
  unless pub
    pub = PublicationType.new
    pub.id = 1
    pub.name = "Journal_Articles"
    pub.save
  end
end
