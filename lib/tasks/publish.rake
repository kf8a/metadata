namespace :publish do
  desc 'publish new datatables'
  task datatables: :environment do
    Datatable.where(on_web: true).where(is_sql: true).where.not(object: nil).all.each do |datatable|
      p datatable
      if !datatable.csv_cache_updated_at
        datatable.publish
      elsif datatable.updated_at > datatable.csv_cache_updated_at
        datatable.publish
      end
    end
  end
end
