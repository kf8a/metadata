# WARNING this is postgres specific

class DataQuery

  def self.find_in_batches_as_csv(query, options={})
    options.assert_valid_keys(:start, :batch_size)

    start = options[:start]
    batch_size = options[:batch_size] || 1000

    count = ActiveRecord::Base.connection.execute("Select count(*) as c from (#{query}) as foo").values.flatten.first.to_i
    (0..count).step(batch_size) do |offset|
      batch_query = "Select * from (#{query}) as foo limit #{batch_size} offset #{offset}"
      yield  self.to_csv_rows(self.find(batch_query))
    end
  end

  def self.find(query)
    ActiveRecord::Base.connection.execute(query)
  end

  def self.to_csv_rows(results)
    results.collect do |row|
      CSV::Row.new(row.keys, row.values).to_s
    end.join
  end

end
