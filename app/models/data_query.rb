# WARNING this is postgres specific

# find data in batches to allow streaming data delivery
class DataQuery
  def self.find_in_batches_as_csv(query, options = {})
    options.assert_valid_keys(:start, :batch_size)
    batch_size = options[:batch_size] || 5_000_000

    (0..count(query)).step(batch_size) do |offset|
      batch_query = "Select * from (#{query}) as foo limit #{batch_size} offset #{offset}"
      yield to_csv_rows(find(batch_query))
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

  def self.count(query)
    ActiveRecord::Base.connection
                      .execute("Select count(*) as c from (#{query}) as foo")
                      .values.flatten
                      .first.to_i
  end
end
