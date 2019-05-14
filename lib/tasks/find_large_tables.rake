namespace :db do
  desc 'find large tables that should not have ordering'
  task large_tables: :environment do
    Datatable.where(on_web: true).where(is_sql: true).where('object is not null').all.each do |row|
      next unless row.object =~ /order/i
      count = ActiveRecord::Base.connection.execute("select count(*) from (#{row.object}) as foo").first
      p [count, row["id"], row["object"]] if count["count"] > 1_000_000
    end
  end
end
