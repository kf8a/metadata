class ChapterCitation < Citation

  def formatted(options={})
    "#{author_and_year(options)}. #{title}. #{publication}, #{volume_and_page}".rstrip
  end

  def volume_and_page
    if volume.blank?
      if page_numbers.blank?
        ""
      else
        "pages #{page_numbers}."
      end
    elsif page_numbers.blank?
      "#{volume}."
    else
      "vol #{volume}, pages #{page_numbers}."
    end
  end

  private

  def book
    publication.blank? ? secondary_title : publication
  end

  def bibtex_type
    :chapter
  end

  def endnote_type
    "CHAP\n"
  end

  def endnote_publication_data
    publication.present? ? "%J #{publication}\n" : ""
  end
end




# == Schema Information
#
# Table name: citations
#
#  id                      :integer         not null, primary key
#  title                   :text
#  abstract                :text
#  pub_date                :date
#  pub_year                :integer
#  citation_type_id        :integer
#  address                 :text
#  notes                   :text
#  publication             :string(255)
#  start_page_number       :integer
#  ending_page_number      :integer
#  periodical_full_name    :text
#  periodical_abbreviation :string(255)
#  volume                  :string(255)
#  issue                   :string(255)
#  city                    :string(255)
#  publisher               :string(255)
#  secondary_title         :string(255)
#  series_title            :string(255)
#  isbn                    :string(255)
#  doi                     :string(255)
#  full_text               :text
#  publisher_url           :string(255)
#  website_id              :integer
#  created_at              :datetime
#  updated_at              :datetime
#  pdf_file_name           :string(255)
#  pdf_content_type        :string(255)
#  pdf_file_size           :integer
#  pdf_updated_at          :datetime
#  state                   :string(255)
#  open_access             :boolean         default(FALSE)
#  type                    :string(255)
#

