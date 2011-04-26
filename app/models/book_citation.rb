class BookCitation < Citation

  def formatted
    "#{author_and_year}. #{title}. #{page_numbers_book}#{editor_string}. #{publication}. #{publisher}, #{address}."
  end

  private

  def bibtex_type
    :book
  end

  def endnote_type
    "Book Section\n"
  end

  def endnote_publication_data
    "%B #{publication}\n" + "%I #{publisher}\n" + "%C #{address}\n"
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
#  type                    :string(255)
#  open_access             :boolean         default(FALSE)
#
