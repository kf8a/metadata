# frozen_string_literal: true

namespace :dois do
  desc 'get latest dois from EDI'
  task edi: :environment do
    # scope = 'knb-lter-kbs'
    datasets = Nokogiri::XML(open('https://pasta.lternet.edu/package/search/eml?defType=edismax&q=*&fq=scope:knb-lter-kbs&fl=packageid,doi,title,responsibleParties,pubdate&sort=score,desc&sort=packageid,asc&debug=false&start=0&rows=100'))
    datasets.xpath('//document').each do |doc|
      title = doc.xpath('title').text
      doi = doc.xpath('doi').text
      pubdate = doc.xpath('pubdate').text
      authors = doc.xpath('responsibleParties').text
      package_id = doc.xpath('packageid').text

      authors.sub!(/Michigan State University\n/, '')
      doi.sub!(/doi:/, 'http://doi.org')

      _, id, _rev = package_id.split('.')

      dataset = Dataset.find_by(metacat_id: id)
      dataset = Dataset.find(id) if dataset.nil?

      core_areas = dataset.datatables.collect do |table|
        table.core_areas.collect(&:name)
      end.flatten.uniq.sort.join(', ')

      citations = "#{authors.sub(/\n/, ' ')}, #{pubdate}. #{title}. #{doi}, [#{core_areas}], https://lter.kbs.msu.edu/datasets/#{dataset.id}\n"
      puts citations

      # datasets.each_line do |dataset|
      #   dataset.chomp!
      #   url = "https://pasta.lternet.edu/package/eml/#{scope}/#{dataset}?filter=newest"
      #   revision = open(url).first
      #   revision.chomp!
      #
      #   # doi_query = "https://pasta.lternet.edu/package/doi/eml/#{scope}/#{dataset}/#{revision}"
      #   # p doi_query
      #   # p open(doi_query).readlines.first
      #
      #   query = "https://pasta.lternet.edu/package/rmd/eml/#{scope}/#{dataset}/#{revision}"
      #   metadata = Nokogiri::XML(open(query))
      #   p metadata.xpath('//doi').text
      #   p metadata.xpath('//packageId').text
    end
  end

  desc 'get dryad dois'
  task dryad: :environment do
    Citation.data_citations.all.each do |pub|
      CSV { |csv_out| csv_out << [pub.formatted(long: true), "https://lter.kbs.msu.edu/citations/#{pub.id}"] }
    end
  end
end
