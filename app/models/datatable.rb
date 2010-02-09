require 'rexml/document'
require 'redcloth'
include REXML

class Datatable < ActiveRecord::Base
  belongs_to :dataset
  has_many :variates, :order => :position
  belongs_to :theme
  belongs_to :core_area
  
  acts_as_taggable_on :keywords
  
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
    data_start_date = data_end_date = nil
    if is_sql
    
      values = ActiveRecord::Base.connection.execute(object)
      date_field = case 
      when values.fields.member?('sample_date') then 'sample_date'
      when values.fields.member?('obs_date') then 'obs_date'
      when values.fields.member?('date') then 'date'
      when values.fields.member?('datetime') then 'datetime'
      end
      unless date_field.nil?
        query = "select max(#{date_field}), min(#{date_field}) from (#{object}) as t1"        
        data_start_date, data_end_date = query_datatable_for_temporal_extent(query)
      end
    end
    {:begin_date => data_start_date,:end_date => data_end_date}
  end
  
  def update_temporal_extent
    dates = temporal_extent
    self.begin_date = dates[:begin_date] if dates[:begin_date]
    self.end_date = dates[:end_date] if dates[:end_date]
    save
  end
  
  ## Finding datatables
  def self.find_by_keywords(keyword_list='')
    self.find_tagged_with(keyword_list,:on => 'keywords')    
  end  
  
  def self.find_by_person(person_id = '')
    return [] if person_id == ''
    if person_id.respond_to?('id')
       person_id = person_id.id
     end
     self.find_by_sql("SELECT datatables.*, datatables.* FROM datatables " +
      " INNER JOIN datasets ON datasets.id = datatables.dataset_id " + 
      " inner join affiliations on datasets.id = affiliations.dataset_id " + 
      " inner join people on affiliations.person_id = people.id " +
      " where people.id = #{person_id}")
  end
  
  def self.find_by_year(syear, eyear)
    
  end
  
  def self.find_by_theme(theme)
    
  end
  
  def self.find_by_study(study)
    
  end
  
  def self.find_by_params(params)
    datatables = self.all
    params.each do |key, value|
      
      method = 'find_by_'+key.to_s
      if value.respond_to?('keys') 
        if value.keys.include?(:id)
          value_id = value[:id]

          unless value_id.nil? || value_id == ''
            datatables = self.send(method.to_sym, value_id) & datatables
          end
        else # we assume that we have a year
          datatables = self.find_by_year(value[:syear], value[:eyear]) & datatables
        end
      else # assume have keywords
        unless value.nil? || value == ''
          datatables = self.send(method.to_sym, value) & datatables
        end
      end
    end
    datatables
  end
  
private

  def query_datatable_for_temporal_extent(query)
    values = ActiveRecord::Base.connection.execute(query)
    [Time.parse(values[0]['min']).to_date,Time.parse(values[0]['max']).to_date]
  end

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
