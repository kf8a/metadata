# frozen_string_literal: true

# generate csv for downloads
module GenerateCsvData
  extend ActiveSupport::Concern
  class_methods do
    # options = "WITH CSV HEADER"
    def stream_query_rows(sql_query, options = "WITH CSV")
      conn = ActiveRecord::Base.connection.raw_connection
      conn.copy_data "COPY (#{sql_query}) TO STDOUT #{options};" do
        while (row = conn.get_copy_data)
          yield row
        end
      end
    end
  end
end
