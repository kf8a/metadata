#Allows customization of search results without using javascript
class Customizer
  def initialize(params, values)
    @params = params
    @values = values
  end

  #Class Methods#

  def self.normalize(array)
    array.compact!
    array.uniq!
    array.sort!
  end

  #Instance Methods#

  def accepts?(row)
    value = row[self.limitby]
    self.accepts_by_contains?(value) &&
        self.accepts_by_max(value) &&
        self.accepts_by_min(value) rescue true
  end

  def accepts_by_contains?(value)
    self.contains.blank? || value.casecmp(self.contains) == 0
  end

  def accepts_by_max(value)
    self.limit_max.blank? || value.casecmp(self.limit_max) <= 0
  end

  def accepts_by_min(value)
    self.limit_min.blank? || value.casecmp(self.limit_min) >= 0
  end

  def customize
    @params[:custom]
  end

  def limitby
    @params[:limitby]
  end

  def limitoptions
    @limitoptions ||= self.setlimitoptions
  end

  def setlimitoptions
    limitoptions = @values.fields.collect do |field|
      next if field == "id"
      [field.titleize, field]
    end
    limitoptions = Customizer.normalize(limitoptions)
  end

  def limit_min
    if self.new_limitby? then nil else @params[:limit_min] end
  end

  def limit_max
    if self.new_limitby? then nil else @params[:limit_max] end
  end

  def limitrange
    @limitrange ||= self.setlimitrange
  end

  def setlimitrange
    limitrange = @values.collect {|row| row[self.limitby]}
    limitrange = Customizer.normalize(limitrange)
  end

  def contains
    if self.new_limitby? then nil else @params[:contains] end
  end

  def oldlimitby
    @params[:oldlimitby] || self.limitby
  end

  def new_limitby?
    self.limitby != self.oldlimitby
  end

  def sortby
    @params[:sortby]
  end

  def sort_direction
    @params[:sort_direction]
  end

  def sorted_values
    values = @values.sort {|firstrow, secondrow| firstrow[self.sortby]<=>secondrow[self.sortby] rescue 0}
    values = values.reverse if self.sort_direction == "Descending"
    values
  end
end