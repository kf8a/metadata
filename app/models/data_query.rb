# WARNING this is postgres specific

# find data in batches to allow streaming data delivery
#
# WARNING: the offset and limit clauses interact with order.
# From the postgresql docs
#
#The query optimizer takes LIMIT into account when generating query plans, so you are very likely to get different plans (yielding different row orders) depending on what you give for LIMIT and OFFSET. Thus, using different LIMIT/OFFSET values to select different subsets of a query result will give inconsistent results unless you enforce a predictable result ordering with ORDER BY. This is not a bug; it is an inherent consequence of the fact that SQL does not promise to deliver the results of a query in any particular order unless ORDER BY is used to constrain the order.


class DataQuery
  def self.find_in_batches_as_csv(query, options = {})
    options.assert_valid_keys(:start, :batch_size)
    batch_size = options[:batch_size] || 10_000_0000

    (0..count(query)).step(batch_size) do |offset|
      batch_query = "Select * from (#{query}) as foo limit #{batch_size} offset #{offset}"
      yield to_csv_rows(find(batch_query))
    end
  end

  def self.find(query)
    ActiveRecord::Base.connection.execute(query)
  end

  def self.to_csv_rows(results)
    p results
    results.collect do |row|
      p row
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
