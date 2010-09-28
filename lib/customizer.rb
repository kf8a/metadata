class Customizer
  def initialize(params, values)
    @params = params
    @values = values
  end

  def accepts?(row)
    self.accepts_by_contains?(row) &&
        self.accepts_by_min(row) &&
        self.accepts_by_max(row)
  end

  def accepts_by_contains?(row)
    self.limitby.blank? ||
        self.contains.blank? ||
        row[self.limitby].casecmp(self.contains) == 0
  end

  def accepts_by_min(row)
    self.limitby.blank? ||
        self.limit_min.blank? ||
        row[self.limitby].casecmp(self.limit_min) >= 0
  end

  def accepts_by_max(row)
    self.limitby.blank? ||
        self.limit_max.blank? ||
        row[self.limitby].casecmp(self.limit_max) <= 0
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
    limitoptions = self.normalize(limitoptions)
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
    limitrange = self.normalize(limitrange)
  end

  def contains
    if self.new_limitby? then nil else @params[:contains] end
  end

  def normalize(array)
    array.compact!
    array.uniq!
    array.sort!
  end

  def oldlimitby
    @params[:oldlimitby]
  end

  def new_limitby?
    self.oldlimitby && self.limitby != self.oldlimitby
  end

  def sortby
    @params[:sortby]
  end

  def sort_direction
    @params[:sort_direction]
  end

  def sorted_values
    values = @values
    values = @values.sort {|a,b| a[self.sortby]<=>b[self.sortby] rescue 0} if self.sort_direction == "Ascending"
    values = @values.sort {|a,b| b[self.sortby]<=>a[self.sortby] rescue 0} if self.sort_direction == "Descending"
    values
  end
end