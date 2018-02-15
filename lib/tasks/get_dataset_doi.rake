# frozen_string_literal: true

require 'edi_report.rb'

namespace :dois do
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
    datasets.xpath('//document').each do |doc|
      package_id = doc.xpath('packageid').text
      _s, identifier, revision = package_id.split(/\./)

      report = EdiReport.new(scope, identifier, revision)

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
