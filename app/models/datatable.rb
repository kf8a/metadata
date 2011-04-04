# encoding: UTF-8

require 'rexml/document'
require 'csv'
require 'iconv'
include REXML

class Datatable < ActiveRecord::Base
  attr_protected :object
  attr_accessor :materialized_datatable_id
  
  acts_as_taggable_on :keywords
  
  has_one                 :collection
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
  
  accepts_nested_attributes_for :data_contributions, :allow_destroy => true
  accepts_nested_attributes_for :variates, :allow_destroy => true

  scope :by_name, :order => 'name'
  
  define_index do
    indexes title
    indexes description
    indexes theme.name, :as => :theme
    indexes people.sur_name, :as => :datatable_sur_name
    indexes people.given_name, :as => :datatable_given_name
    indexes dataset.affiliations.person.sur_name, :as => :sur_name
    indexes dataset.affiliations.person.given_name, :as => :given_name
    indexes taggings.tag.name, :as => :keyword_name
    indexes dataset.title, :as => :dataset_title
    indexes dataset.dataset, :as => :dataset_identifier
    indexes name
    has dataset.website_id, :as => :website
    where "datatables.on_web is true and datasets.on_web"

    #set_property :field_weights => {:keyword => 20, :theme => 20, :title => 10}
  end

  def to_label
    "#{title} (#{name})"
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
    permitted = !self.owners.empty? && !user.blank?
    self.owners.each do |owner|
      permitted = (permitted && user.has_permission_from?(owner, self))
    end
    permitted
  end
  
  def requesters
    requests = PermissionRequest.find_all_by_datatable_id(self.id)
    requesters = []
    requests.each do |request|
      user = request.user
      next if self.permitted?(user)
      requesters << user
    end
    requesters
  end

  def requested_by?(user)
    request = PermissionRequest.find_by_datatable_id_and_user_id(self.id, user.id)
    !request.blank?
  end

  def deniers_of(user)
    permissions.collect {|x| (x.user == user) && (x.decision == "denied") ? x.owner : nil}.compact
  end
  
  def can_be_downloaded_by?(user)
    !self.restricted? or
      user.try(:admin?) or
      self.owned_by?(user) or
      member?(user) or
      self.permitted?(user)
  end

  def owned_by?(user)
    user.try(:owns?, self)
  end

  def member?(user)
    sponsors = user.try(:sponsors)
    sponsors.respond_to?('include?') ? sponsors.include?(self.dataset.try(:sponsor)) : false
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
    {'dateTimeFormat'=> 'Gregorian', 'events'=> events}.to_json
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
    eml = Element.new('dataTable')
    eml.add_attribute('id',name)
    eml.add_element('entityName').add_text(title)
    eml.add_element('entityDescription').add_text(description.gsub(/<\/?[^>]*>/, ""))
    eml.add_element eml_physical
#    eml.add_element eml_coverage
    eml.add_element eml_attributes
#    eml.add_element('numberOfRecords').add_text()
    return eml
  end
  
  def to_csv(version = nil)
    values  = perform_query(limited = false).values
    csv_string = CSV.generate do |csv|
      csv << variates.collect {|v| v.name }
      values.each do |row|
        csv << variates.collect do |v|
          row[v.name.downcase]
        end
      end
    end
    # mtable.data = csv_string
    # mtable.save
    csv_string
  end
  
  def to_csv_with_metadata(version = nil)
    # stupid microsofts
    csv_string = to_csv(version).force_encoding("UTF-8")
    result = ""
    result = data_access_statement + data_source + data_comments + csv_string
    if is_utf_8
      result = Iconv.conv('utf-16','utf-8', result)
    end
    result
  end

  def to_climdb
    csv_string = to_csv
    '!' + csv_string
  end
  
  def to_xls
 
  end
  
#   def to_ods
#     values = perform_query(limited=false)
#     sheet = Spreadsheet::Builder.new
#     sheet.spreadsheet do 
#       sheet.table "Data Use Policy" do
#         data_access_statement.each_line do |line|
#           sheet.row do 
#             sheet.cell line
#           end
#         end
#         data_source.each_line do |source|
#           sheet.row do
#             sheet.cell source
#           end
#         end
#         sheet.cell data_comments
#       end
#       
#       sheet.table "Data" do
#         sheet.header do
#        
#           sheet.row do
#             variates.each do |variate|
#               sheet.cell variate.name
#             end
#           end
#         end
#         values.each do |elements|
#           sheet.row do  
#             elements.values.each do |element| 
#               sheet.cell element
#             end
#           end
#         end
#       end
#     end
#     sheet.content!
#   end
    
  def data_comments
    comments ?  comments.gsub(/^/,'#') + "\n" : ''
  end
  def data_contact
    # contact = self.dataset.principal_contact
    # "#{contact.full_name} #{contact.email} #{contact.phone}"
  end
  
  def data_source
    mtable = MaterializedDatatable.find_by_datatable(id)
    "\n# Data Source: http://#{sponsor_name}.kbs.msu.edu/datatables/#{self.id}
# This version of the data http://#{sponsor_name}.kbs.msu.edu/datatables/#{self.id}.csv?version=#{mtable.version_number}
# The newest version of the data http://#{sponsor_name}.kbs.msu.edu/datatables/#{self.id}.csv
# Full EML Metadata: http://#{sponsor_name}.kbs.msu.edu/datatables/#{self.id}.eml\n#\n#"
  end
  
  def data_access_statement
    access_statement = dataset.sponsor.try(:data_use_statement)
    if access_statement
      access_statement.gsub(/.{1,60}(?:\s|\Z)/){($& + 5.chr)\
        .gsub(/\n\005/,"\n")\
        .gsub(/\005/,"\n")}\
        .split(/\n/)\
        .collect {|line| "# #{line}\n"}\
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

  def data_preview
    query =  self.object
    self.excerpt_limit = 5 unless self.excerpt_limit
    query = query + " limit #{self.excerpt_limit}" 
    ActiveRecord::Base.connection.execute(query)
  end
  

  # performs the database query to retrieve the actual data
  # the version number can be used to specify a version of the data
  # if the version is nil or does not exist it will return the most
  # recent version of the data returns a materialized_datatable
  def perform_query(version = nil)
    query =  self.object
    if version
      table = MaterializedDatatable.find_by_datatable_and_version(self.id, version)
    else
      #try to find it
      table = MaterializedDatatable.find_by_datatable(self.id)
      if table
        result = ActiveRecord::Base.connection.execute(query)
        table.values = result
        table.fields = result.fields
        table.save
        result.clear
      else
        result = ActiveRecord::Base.connection.execute(query)
        table = MaterializedDatatable.create({:datatable => id, :values => result, :fields => result.fields})
        table.save
        result.clear
      end
    end
    table # return the materialized_datatable
  end

  def related_tables
    self.dataset.datatables - [self]
  end
  
  def values
    values = nil
    values = self.perform_query if self.is_sql
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
    dataformat.add_element('numHeaderLines').add_text((data_access_statement.lines.to_a.size + 4).to_s)
    dataformat.add_element('attributeOrientation').add_text('column')
    dataformat.add_element('simpleDelimited').add_element('fieldDelimiter').add_text(',')
    p.add_element('distribution').add_element('online').add_element('url').add_text(data_url)
    return p
  end
  
  def eml_coverage
    # e = Element.new('coverage')
    # e.add_element eml_geographic_coverage
    # e.add_element eml_temporal_coverage
    # e.add_element eml_taxonomic_coverage
    # e
  end
  
  def eml_geographic_coverage
    
  end
  
  def eml_temporal_coverage
    
  end
  
  def eml_taxonomic_coverage
    
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
