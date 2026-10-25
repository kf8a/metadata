# frozen_string_literal: true

namespace :db do
  desc 'find large tables that should not have ordering'
  task large_tables: :environment do
    Datatable.where(on_web: true).where(is_sql: true).where.not(object: nil).all.each do |row|
      next unless row.object =~ /order/i

      count = row.total_records
      p [count, row.id, row.object] if count > 1_000_000
    end
  end
end
