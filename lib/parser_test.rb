# encoding: UTF-8

require 'polyglot'
require 'treetop'
#require 'citrus'
require 'active_record'


ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "../db/appdb",
)

require 'paperclip'
require '../app/models/citation'
require '../app/models/author'
require 'ris'
require 'ris_nodes'

#Citrus.load('ris')

parser = RISParser.new

parser.consume_all_input = false

#file = File.open('../test/data/GLBRC_Publications_Thrust4.ris',"r:UTF-8")
file = File.open('../test/data/multiple.ris',"r:UTF-8")

#file = File.open('../test/data/single.ris',"r:UTF-8")

content = file.read
#p content
a = parser.parse(content)
#a = parser.parse("TY  - test\r\nAB  - This is an abstract\r\nwith two lines\r\nUR  - url format\r\nER  - \r\n")
#p a
p a.content