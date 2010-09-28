#This controller allows searching and sorting of a datatable's data through
#a "collection" of its data.
class CollectionsController < ApplicationController

  layout :site_layout
  
  before_filter :get_collection, :only => :show
  before_filter :set_values, :only => :show

  def index
    @collections = Collection.all
  end
  
  def show
    @customize = params[:custom]
    @customizer = Customizer.new(params, @values)
    @values = @customizer.sort_values(@values)
  end

  private
  
  def get_collection
    @collection = Collection.find(params[:id])
  end

  def set_limitrange(values, limitby)
    @limitrange = values.collect {|row| row[limitby]}
    @limitrange = normalize(@limitrange)
  end

  def set_values
    @values = @collection.perform_query
  end
end

class Customizer
  def initialize(params, values)
    @params = params
    @values = values
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

  def sort_values(values)
    values = values.sort {|a,b| a[self.sortby]<=>b[self.sortby] rescue 0} if self.sort_direction == "Ascending"
    values = values.sort {|a,b| b[self.sortby]<=>a[self.sortby] rescue 0} if self.sort_direction == "Descending"
    values
  end

end