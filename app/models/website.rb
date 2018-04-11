# GLBRC and LTER have different information; Website is used to separate it.
class Website < ApplicationRecord
  has_many :datasets
  has_many :templates
  has_and_belongs_to_many :protocols
  has_many :study_urls
  has_many :citations

  has_many :article_citations
  has_many :book_citations
  has_many :chapter_citations
  has_many :thesis_citations
  has_many :report_citations
  has_many :bulletin_citations
  has_many :data_citations

  validates :name, uniqueness: true
  validates :name, presence: true

  # def layout(controller, action)
  #   template = self.templates.where(controller: controller, action: action)
  #   Liquid::Template.parse(template.layout) if template
  # end
end
