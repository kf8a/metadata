# lib/tasks/search.rake
namespace :search do
  desc 'Import all Rails content (default target: the live alias)'
  task :import_rails, [:collection] => :environment do |_t, args|
    target = args[:collection] || SiteSearch::ALIAS
    [Citation].each do |model|
      model.find_each.each_slice(200) do |batch|
        docs = batch.select(&:search_indexable?).map(&:search_document)
        SiteSearch.bulk_upsert(docs, collection: target) if docs.any?
      end
    end
  end
end
