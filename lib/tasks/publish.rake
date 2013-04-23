namespace :publish do
  desc 'publish new datatables'
  task :datatables do
    Datatables.all.each do |datatable|
      if datatable.updated_at > datatable.csv_cache_updated_at
        datatable.publish
      end
    end
  end
end
