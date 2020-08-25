# frozen_string_literal: true

# GLBRC and LTER have different information; Website is used to separate it.
class Website < ApplicationRecord
  has_many :datasets, dependent: :nullify
  has_many :templates, dependent: :nullify
  has_and_belongs_to_many :protocols
  has_many :study_urls, dependent: :nullify
  has_many :citations, dependent: :nullify

  has_many :article_citations, dependent: :nullify
  has_many :book_citations, dependent: :nullify
  has_many :chapter_citations, dependent: :nullify
  has_many :thesis_citations, dependent: :nullify
  has_many :report_citations, dependent: :nullify
  has_many :bulletin_citations, dependent: :nullify
  has_many :data_citations, dependent: nullify

  validates :name, uniqueness: true
  validates :name, presence: true

  # def layout(controller, action)
  #   template = self.templates.where(controller: controller, action: action)
  #   Liquid::Template.parse(template.layout) if template
  # end
end
