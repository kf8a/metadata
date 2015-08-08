class DataQuery
  # def self.find_in_batches(query, size, &block)
  #   batch_query = "Select * from (#query) limit #{size} offset #{offset}"
  #   yield  self.find(batch_query)
  # end

  def self.find(query)
    ActiveRecord::Base.connection.execute(query)
  end

end
