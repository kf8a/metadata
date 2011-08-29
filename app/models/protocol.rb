class Protocol < ActiveRecord::Base
  belongs_to :dataset
  has_and_belongs_to_many :websites
  has_and_belongs_to_many :datatables
  has_many :scribbles
  has_many :people, :through => :scribbles

  versioned :dependent => :tracking

  def to_s
    "#{self.title}"
  end

  def self.from_eml(method_eml)
    protocol_eml = method_eml.css('protocol').first
    prot_id = protocol_eml.attributes['id'].try(:value).try(:gsub, 'protocol_', '')
    protocol = Protocol.find_by_id(prot_id)
    unless protocol.present?
      protocol = Protocol.new
      protocol.title = protocol_eml.css('title').text
      protocol.abstract = method_eml.css('abstract').text
      protocol.save
    end

    protocol
  end

  def valid_for_eml?
    title.present?
  end

  def to_eml(xml = Builder::XmlMarkup.new)
    @eml = xml
    @eml.methodStep do
      @eml.description abstract
      @eml.protocol 'id' => "protocol_#{id}" do

        @eml.title  title
        eml_creator
        @eml.distribution do
          @eml.online do
            website_name = dataset.try(:website).try(:name) || websites.first.try(:name)
            @eml.url "http://#{website_name}.kbs.msu.edu/protocols/#{id}"
          end
        end
      end

    end
  end

  def to_eml_ref(xml = Builder::XmlMarkup.new)
    # xml.methodStep do
    #   xml.protocol do
    #     xml.references "protocol_#{self.id}"
    #   end
    # end
  end

  def deprecate!(other)
    other.active = false
    other.save
    self.deprecates = other.id
    self.version_tag = other.version_tag.to_i + 1
    save
  end

  def replaced_by
    Protocol.where(:deprecates => self.id).first
  end

  def dataset_description
    self.dataset.try(:dataset)
  end


  private

  def eml_creator
    @eml.creator do
      @eml.positionName 'Data Manager'
    end
  end
end

# == Schema Information
#
# Table name: protocols
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  title          :string(255)
#  version_tag    :integer
#  in_use_from    :date
#  in_use_to      :date
#  description    :text
#  abstract       :text
#  body           :text
#  person_id      :integer
#  created_on     :date
#  updated_on     :date
#  change_summary :text
#  dataset_id     :integer
#  active         :boolean         default(TRUE)
#  deprecates     :integer
#
