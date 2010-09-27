#require 'UnitDictionary'

class UnitUpdateJob < Struct.new(:unit) 
  def perform
    # #updating units
    #  u = DictionaryUnit.find(unit.dictionary_id)
    #  unless u
    #    u = DictionaryUnit.find(unit.name)
    #  end
    #  # if u
    #  #   unit.update_attributes :description => u.description, 
    #  #                          :name        =>  u.name
    #  #                          :deprecated_in_favor_of => u.deprecated_in_favor_of                             
    #  # 
    #  #   unit.save
    #  # end
   end
end

class UnitDictionaryUpdateJob < Struct.new(:unit)
  #   u = DictionaryUnit.new :description => unit.description,
  #       :name => unit.name, :deprecated_in_favor_of => deprecated_in_favor_of
  #   u.save
end