Given /^(\d+) is published$/ do |id|
  Citation.find(id).publish!
end
