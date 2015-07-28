# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

VenueType.where(name: 'local').first_or_create
VenueType.where(name: 'national').first_or_create
VenueType.where(name: 'other').first_or_create

Website.where(name: 'lter').first_or_create
Website.where(name: 'glbrc').first_or_create

Sponsor.where(name: 'glbrc').first_or_create
