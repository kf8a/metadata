# encoding: UTF-8

# from http://github.com/maximkulkin/spreadsheet

require 'spreadsheet/builder'

# Spreadsheet::XmlBuilder = begin
#   require 'spreadsheet/libxml_xml_builder'
#   Spreadsheet::LibxmlXmlBuilder
# rescue LoadError  
  require 'spreadsheet/builder_xml_builder'
Spreadsheet::XmlBuilder =  Spreadsheet::BuilderXmlBuilder
# end

if defined?(Rails.env)
  require 'action_view'

  Mime::Type.register 'application/vnd.oasis.opendocument.spreadsheet', :ods

  require 'spreadsheet/template_handler'
  ActionView::Template.register_template_handler :rsheet, Spreadsheet::TemplateHandler
end

