require 'rexml/document'
require 'redcloth'
include REXML

class Datatable < ActiveRecord::Base
  belongs_to :dataset
  has_many :variates, :order => :position
  
  def within_interval?(start_date=Date.today, end_date=Date.today)
    extent = temporal_extent
    return false if extent[:begin_date].nil?
    
    !(extent[:begin_date] < start_date || extent[:end_date] > end_date) 
  end
      
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
  
  def temporal_extent
    data_start_date = nil
    data_end_date = nil
    if is_sql
    
      values = ActiveRecord::Base.connection.execute(object)
      if values.fields.member?('sample_date')
    
        query = "select max(sample_date), min(sample_date) from (#{object}) as t1"
    
        values = ActiveRecord::Base.connection.execute(query)
        data_start_date = Time.parse(values[0]['min']).to_date
        data_end_date = Time.parse(values[0]['max']).to_date
      end
    end
    {:begin_date => data_start_date,:end_date => data_end_date}
  end
  
  def update_temporal_extent
    dates = temporal_extent
    self.begin_date = dates[:begin_date]
    self.end_date = dates[:end_date]
    save
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
  
  def convert_to_date(time)
    if time.class == Time
        time = time.to_date
    end
    time
  end
end
