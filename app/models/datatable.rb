require 'rexml/document'
require 'redcloth'
#require 'fastercsv'
include REXML

class Datatable < ActiveRecord::Base
  belongs_to :dataset
  has_many :variates, :order => :position
    
  def to_eml
    eml = Element.new('datatable')
    eml.add_attribute('id',name)
    eml.add_element('entityName').add_text(title)
    eml.add_element('entityDescription').add_text(description.gsub(/<\/?[^>]*>/, ""))
    eml.add_element eml_physical
    eml.add_element eml_attributes
#    eml.add_element('numberOfRecords').add_text()
    return eml
  end
  
  def to_csv
    p 'in_csv'
    if self.is_restricted
      return 'Data Embargoed'
    end
    values  = ActiveRecord::Base.connection.execute(object)
    csv_string = FasterCSV.generate do |csv|
      csv << variates.collect {|v| v.name }
      values.each do |row|
        csv << row
      end
    end
    # delete empty string values
    csv_string.gsub!(/\,\"\"/,',')
    return  csv_string
  end
  
private
  def eml_physical
    p = Element.new('physical')
    p.add_element('objectName').add_text(self.title)
    p.add_element('encodingMethod').add_text('None')
    dataformat = p.add_element('dataFormat').add_element('textFormat')
    dataformat.add_element('attributeOrientation').add_text('column')
    dataformat.add_element('simleDelimiter').add_element('fieldDelimiter').add_text(',')
    p.add_element('distribution').add_element('online').add_element('url').add_text(data_url)
    return p
  end
  
  def eml_attributes
    a = Element.new('attributeList')
    self.variates.each do |variate|
      a.add_element variate.to_eml
    end
    return a
  end
end
