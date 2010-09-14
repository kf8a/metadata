# encoding: UTF-8

require 'polyglot'
require 'treetop'
require 'active_record'


ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database =>":memory:"
)

load "../db/schema.rb"

require '../config/environment'

require 'ris'
require 'ris_nodes'

#Citrus.load('ris')

parser = RISParser.new

parser.consume_all_input = false


file = File.open('../test/data/GLBRC_Publications_Thrust4.ris',"r:UTF-8")
#file = File.open('../test/data/single.ris',"r:UTF-8")

content = file.read

a = parser.parse(content)
#a = parser.parse("TY  - JOUR\r\nAB  - This is an abstract\r\nWith two lines\r\nUR  - url format\r\nER  - \r\n")
#a = parser.parse("TY  - JOUR\r\nER  - \r\n")

a.write_dot_file('test')
p parser.failure_reason
p a.content('test/data')