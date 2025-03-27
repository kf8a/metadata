namespace :eml do
    desc "Generate EML for a dataset and print to stdout (specify id with DATASET_ID=x)"
    task generate: :environment do
      dataset_id = ENV['DATASET_ID']

      unless dataset_id
        puts "Please specify a dataset ID with DATASET_ID=x"
        exit 1
      end

      begin
        dataset = Dataset.find(dataset_id)
        builder = EmlDatasetBuilder.new(dataset)
        eml_output = builder.to_eml

        puts eml_output
      rescue ActiveRecord::RecordNotFound
        warn "Dataset with ID #{dataset_id} not found"
        exit 1
      rescue => e
        warn "Error generating EML: #{e.message}"
        warn e.backtrace
        exit 1
      end
    end
  end