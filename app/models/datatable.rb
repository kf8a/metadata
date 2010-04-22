# encoding: UTF-8

require 'rexml/document'
require 'csv'
include REXML

class Datatable < ActiveRecord::Base
  attr_protected :object
  belongs_to :dataset
  has_many :variates, :order => :weight
  belongs_to :theme
  belongs_to :core_area
  belongs_to :study
  
  has_many :data_contributions
  has_many :people, :through => :data_contributions
    
  validates_presence_of :title
  
  accepts_nested_attributes_for :data_contributions
  
  accepts_nested_attributes_for :variates
  
  acts_as_taggable_on :keywords
  
  define_index do
    indexes title
    indexes description
    indexes theme.name, :as => :theme
    indexes dataset.affiliations.person.sur_name, :as => :sur_name
    indexes dataset.affiliations.person.given_name, :as => :given_name
    indexes keywords(:name), :as => :keyword
    indexes dataset.title, :as => :dataset_title
    indexes dataset.dataset, :as => :dataset_identifier
    indexes name
    where "datatables.on_web is true and datasets.on_web"
    
    #set_property :field_weights => {:keyword => 20, :theme => 20, :title => 10}
  end
  
  def personnel
    h = datatable_personnel
    if h.empty?
      h = dataset_personnel
    end
    h
  end
  
  def datatable_personnel(h = {})
    data_contributions.each do |contribution|
      if h[contribution.person]
        h[contribution.person] = h[contribution.person].push((contribution.role.name))
      else
        h[contribution.person] = [contribution.role.name]
      end
    end
    h
  end
  
  def dataset_personnel(h = {})
    dataset.affiliations.each do |contribution|
      if h[contribution.person]
        h[contribution.person] = h[contribution.person].push((contribution.role.name))
      else
        h[contribution.person] = [contribution.role.name]
      end
    end
    h 
  end
  
  def within_interval?(start_date=Date.today, end_date=Date.today)
    extent = temporal_extent
    return false if extent[:begin_date].nil?
    
    !(extent[:begin_date] < start_date || extent[:end_date] > end_date) 
  end
  
  #TODO create a completed flag and use the actual end year if present
  def title_and_years
    return title if (self.begin_date.nil? or self.end_date.nil?)
    year_end = end_date.year
    year_start = begin_date.year
    reply = ""
    if year_end == year_start
      reply = " (#{year_start})"
    else
      reply = " (#{year_start} to #{ year_end > Time.now.year - 3 ? 'present': year_end})"
    end
    title + reply
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
    if RUBY_VERSION > "1.9"
      output = CSV
    else
      output = FasterCSV
    end
    csv_string = output.generate do |csv|
      csv << variates.collect {|v| v.name }
      values.each do |row|
        csv << row.values
      end
    end
    csv_string
  end
  
  def to_csv_with_metadata
    # stupid microsofts
    result = data_access_statement + data_source +  to_csv
    if is_utf_8
      result = Iconv.conv('utf-16','utf-8', result)
    end
    result
  end

  def to_climdb
    csv_string = to_csv
    '!' + csv_string
  end
    
  def data_contact
    # contact = self.dataset.principal_contact
    # "#{contact.full_name} #{contact.email} #{contact.phone}"
  end
  
  def data_source
    "#\n# Data Source: http://lter.kbs.msu.edu/datatables/#{self.id}
# Metadata: http://lter.kbs.msu.edu/datatables/#{self.id}.eml\n#\n#"
  end
  
  def data_access_statement
    "# Terms of Use
#   Data in the KBS LTER core database may not be published without written permission of the lead investigator
#   or project director. These restrictions are intended mainly to preserve the primary investigators' rights
#   to first publication and to ensure that data users are aware of the limitations that may be associated with
#   any specific data set. These restrictions apply to both the baseline data set and to the data sets associated
#   with specific LTER-supported subprojects.\n#
#   All investigators on-site are expected to release their data to the core database within
#   a reasonable period of time following subproject completion.\n#
#   Access to data is provided by the KBS LTER Data Manager with oversight provided by the Executive Committee,
#   chaired by the Project Director. Access to sample archives is provided by the Project Director.
#   All publications of KBS data and images must acknowledge KBS LTER support.\n"
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
      when values.fields.member?('year') then 'year'
      when values.fields.member?('harvest_date') then 'harvest_date'
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
    
private

  def query_datatable_for_temporal_extent(query)
    values = ActiveRecord::Base.connection.execute(query)
    if values[0].class == 'Date' 
      [Time.parse(values[0]['min']).to_date,Time.parse(values[0]['max']).to_date]
    else # assume is a year
      [Time.parse(values[0]['min'].to_s + '-1-1').to_date,Time.parse(values[0]['max'].to_s + '-1-1').to_date ]
    end
  end

  def eml_physical
    p = Element.new('physical')
    p.add_element('objectName').add_text(self.title)
    p.add_element('encodingMethod').add_text('None')
    dataformat = p.add_element('dataFormat').add_element('textFormat')
    dataformat.add_element('attributeOrientation').add_text('column')
    dataformat.add_element('simpleDelimiter').add_element('fieldDelimiter').add_text(',')
    dataformat.add_element('numHeaderLines').add_text('18')
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
