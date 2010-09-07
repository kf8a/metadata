# encoding: UTF-8

require 'rexml/document'
require 'csv'
include REXML

class Datatable < ActiveRecord::Base
  attr_protected :object
  
  belongs_to              :core_area
  belongs_to              :dataset
  has_many                :data_contributions
  has_many                :owners, :through => :ownerships, :source => :user
  has_many                :ownerships
  has_many                :people, :through => :data_contributions
  has_many                :permissions
  has_and_belongs_to_many :protocols
  belongs_to              :study
  belongs_to              :theme
  has_many                :variates, :order => :weight
    
  validates_presence_of :title, :dataset
  
  accepts_nested_attributes_for :data_contributions, :variates
  
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
    has dataset.website_id, :as => :website
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
  
  def datatable_personnel
    compile_personnel(data_contributions)
  end
  
  def dataset_personnel
    compile_personnel(dataset.affiliations)
  end
  
  def compile_personnel(source, h={})
    source.each do |contribution|
      if h[contribution.person]
        h[contribution.person] = h[contribution.person].push((contribution.role.name))
      else
        h[contribution.person] = [contribution.role.name]
      end
    end
    h
  end
  
  def restricted?
    dataset.sponsor.try(:data_restricted?)
  end
  
  def permitted?(user)
    permissions_granted_by = permissions.collect {|x| x.user == user ? x.owner : nil}.compact
    permissions_granted_by == owners and not owners.empty?
  end
  
  #TODO need to decide wether the permissions stuff is a function of the user or the datatable
  def can_be_downloaded_by?(user)
    !self.restricted? or
      user.try(:role) == 'admin' or
      self.is_owned_by?(user) or
      self.permitted?(user)
  end

  def is_owned_by?(user)
    user.try(:owns?, self)
  end
  
  def within_interval?(start_date=Date.today, end_date=Date.today)
    extent = temporal_extent
    return false if extent[:begin_date].nil?
    
    !(extent[:begin_date] < start_date || extent[:end_date] > end_date) 
  end
  
  def events
    event_query_sql = event_query || ""
    values  = ActiveRecord::Base.connection.execute(event_query_sql)
    
    events = values.collect do |value|
      {'start' => Date.parse(value['date']).rfc2822,
        'title' => value['title'],
        'description' => value['description'],
       'durationEvent' => false }
    end
    
    event_summary = events.inject do |event|
      
    end
    {'dateTimeFormat'=> 'Gregorian', 'events'=> event_summary}.to_json
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
    if self.metadata_only?
      return 'Data available by request from glbrc.data@kbs.msu.edu'
    end
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
    # TODO test if file exists and send that
    
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
    "\n# Data Source: http://#{sponsor_name}.kbs.msu.edu/datatables/#{self.id}
# Metadata: http://#{sponsor_name}.kbs.msu.edu/datatables/#{self.id}.eml\n#\n#"
  end
  
  def data_access_statement
    access_statement = dataset.sponsor.try(:data_use_statement)
    if access_statement
      access_statement.gsub(/.{1,60}(?:\s|\Z)/){($& + 5.chr)
        .gsub(/\n\005/,"\n")
        .gsub(/\005/,"\n")}
        .split(/\n/)
        .collect {|line| "# #{line}\n"}
        .join
    else
      ''
    end
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
  
  def perform_query
    query =  self.object
    self.excerpt_limit = 5 unless self.excerpt_limit
    query = query + " limit #{self.excerpt_limit}" 
    ActiveRecord::Base.connection.execute(query)
    #TDOD convert the array into a ruby object
  end

  def related_tables
    self.dataset.datatables - [self]
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
  
  def sponsor_name
    dataset.sponsor.try(:name) || 'LTER'
  end
  
end
