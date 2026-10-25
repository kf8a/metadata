# frozen_string_literal: true

# Allows customization of search results without using javascript
class Customizer
  def initialize(params, values)
    @params = params
    @values = values
  end

  # Class Methods#

  def self.normalize(array)
    array.compact!
    array.uniq!
    array.sort!
  end

  # Instance Methods#

  def accepts?(row)
    value = row[limitby]
    begin
      accepts_by_contains?(value) &&
      accepts_by_max(value) &&
      accepts_by_min(value)
    rescue StandardError
      true
    end
  end

  def accepts_by_contains?(value)
    contains.blank? || value.casecmp(contains) == 0
  end

  def accepts_by_max(value)
    limit_max.blank? || value.casecmp(limit_max) <= 0
  end

  def accepts_by_min(value)
    limit_min.blank? || value.casecmp(limit_min) >= 0
  end

  def customize
    @params[:custom]
  end

  def limitby
    @params[:limitby]
  end

  def limitoptions
    @limitoptions ||= setlimitoptions
  end

  def setlimitoptions
    limitoptions = @values.fields.collect do |field|
      next if field == 'id'

      [field.titleize, field]
    end
    Customizer.normalize(limitoptions)
  end

  def limit_min
    @params[:limit_min] unless new_limitby?
  end

  def limit_max
    @params[:limit_max] unless new_limitby?
  end

  def limitrange
    @limitrange ||= setlimitrange
  end

  def setlimitrange
    limitrange = @values.collect { |row| row[limitby] }
    Customizer.normalize(limitrange)
  end

  def contains
    @params[:contains] unless new_limitby?
  end

  def oldlimitby
    @params[:oldlimitby] || limitby
  end

  def new_limitby?
    limitby != oldlimitby
  end

  def sortby
    @params[:sortby]
  end

  def sort_direction
    @params[:sort_direction]
  end

  def sorted_values
    values = @values.sort do |firstrow, secondrow|
      firstrow[sortby] <=> secondrow[sortby]
    rescue StandardError
      0
    end
    sort_direction == "Descending" ? values.reverse : values
  end
end
