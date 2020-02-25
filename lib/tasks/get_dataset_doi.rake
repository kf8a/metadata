# frozen_string_literal: true

require 'edi_report.rb'
require 'faraday'

namespace :dois do
  desc 'update dois from edi'
  task update_from_edi: :environment do
    scope = 'knb-lter-kbs'
    p Dataset.where('website_id = 1 and sponsor_id = 1').first
    Dataset.where('website_id = 1 and sponsor_id = 1').find_each do |dataset|
      p dataset
      identifier = dataset.metacat_id || dataset.id
      url = "https://pasta.lternet.edu/package/eml/#{scope}/#{identifier}"
      response = Faraday.get url
      if response.status == 200
        response.body.each_line do |revision|
          revision = revision.to_i
          url = "https://pasta.lternet.edu/package/doi/eml/#{scope}/#{identifier}/#{revision}"
          response = Faraday.get url
          next unless response.body =~ /doi/

          doi = DatasetDoi.new(doi: response.body, version: revision)

          dataset.dataset_dois << doi
          p [dataset.id, dataset.title, doi]
          dataset.save
        end
      end
    end
  end

  desc 'get latest dois from EDI'
  task edi: :environment do
    scope = 'knb-lter-kbs'
    max_rows = 1000
    url =
      "https://pasta.lternet.edu/package/search/eml?defType=edismax&q=*&fq=scope:#{scope}&rows=#{max_rows}&fl=packageid"

    datasets = Nokogiri::XML(open(url))

    puts EdiReport.table_header
    puts EdiReport.table_spacer

    i = 0
    reports = datasets.xpath('//document').collect do |doc|
      package_id = doc.xpath('packageid').text
      _s, identifier, revision = package_id.split(/\./)

      EdiReport.new(scope, identifier, revision).load
    end.compact

    reports.sort! { |a, b| a.first_author_name <=> b.first_author_name }

    reports.each do |report|
      i += 1
      puts "#{report.table_row(i)}\n"
    end
  end

  desc 'get dryad dois'
  task dryad: :environment do
    Citation.data_citations.all.each do |pub|
      CSV { |csv_out| csv_out << [pub.formatted(long: true), "https://lter.kbs.msu.edu/citations/#{pub.id}"] }
    end
  end
end
