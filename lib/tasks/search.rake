# frozen_string_literal: true

namespace :search do
  desc 'Import all Rails content (default target: the live alias)'
  task :import_rails, [:collection] => :environment do |_t, args|
    target = args[:collection] || SiteSearch::ALIAS

    models = {
      Citation => [:authors, :website, :treatments],
      Datatable => [
        :theme,
        :study,
        :variates,
        :keywords,
        { dataset: :website },
        { data_contributions: %i[person role] }
      ],
      Protocol => [
        :websites,
        :themes,
        :datatables,
        :people,
        { dataset: :website }
      ]
    }

    models.each do |model, includes|
      indexed = 0
      skipped = 0

      puts "Importing #{model.name} into #{target}..."

      model.includes(includes).find_each.each_slice(200) do |batch|
        indexable, not_indexable = batch.partition(&:search_indexable?)
        skipped_ids = not_indexable.map(&:id)
        skipped += skipped_ids.size

        if skipped_ids.any?
          puts "  #{model.name}: skipped ids #{skipped_ids.join(', ')}"
        end

        docs = indexable.map(&:search_document)
        next if docs.empty?

        SiteSearch.bulk_upsert(docs, collection: target)
        indexed += docs.size
        puts "  #{model.name}: indexed #{indexed} (skipped #{skipped})"
      end

      puts "  #{model.name}: done — indexed #{indexed}, skipped #{skipped}"
    end
  end
end
