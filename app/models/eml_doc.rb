class EmlDoc < ActiveRecord::Base
  
  def file=(file)
    doc = REXML::Document.new file
    datasets = []
    doc.root.elements['//dataset'].each do |dataset|
      dataset = Dataset.new
      dataset.from_eml(dataset)
      datasets << dataset
    end
  end
  
  def file(data)
  end
end
