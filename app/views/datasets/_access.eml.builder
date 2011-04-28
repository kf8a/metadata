xml.access 'scope' => 'document', 'order' => 'allowFirst', 'authSystem' => 'knb' do
  xml << eml_allow('uid=KBS,o=lter,dc=ecoinformatics,dc=org', 'all')
  xml << eml_allow('public','read')
end