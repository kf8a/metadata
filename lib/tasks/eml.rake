# frozen_string_literal: true

namespace :eml do
  desc "Generate EML for a dataset and print to stdout (specify id with DATASET_ID=x)"
  task generate: :environment do
    dataset_id = ENV.fetch('DATASET_ID', nil)

    unless dataset_id
      puts "Please specify a dataset ID with DATASET_ID=x"
      exit 1
    end

    begin
      url = "https://lter.kbs.msu.edu/datasets/#{dataset_id}.eml"
      response = Faraday.get(url)
      if response.status == 200
        EmlFileIntegrity.generate(response.body)
      else
        puts "Error: #{response.status} #{response.body}"
      end
    rescue Faraday::ConnectionFailed => e
      puts "Error: #{e.message}"
      exit 1
    end
  end
end
