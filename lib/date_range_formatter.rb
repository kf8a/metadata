# frozen_string_literal: true

# Formats a year range for the titles
class DateRangeFormatter
  def self.year_range(daterange)
    starting = daterange[:begin_date]
    ending   = daterange[:end_date]
    if starting && ending
      format_date_range(starting.year, ending.year)
    elsif starting
      " (#{starting.year})"
    else
      ''
    end
  end

  def self.format_date_range(start_year, end_year)
    if start_year == end_year
      " (#{start_year})"
    else
      " (#{start_year} to #{end_year})"
    end
  end
end
