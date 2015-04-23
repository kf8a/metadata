# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://lter.kbs.msu.edu"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
  website = Website.where(name: 'lter').first
  add datatables_path, :priority => 0.9, :changefreq => 'daily'
  add datasets_path 
  website.datasets.each do |dataset|
    add dataset_path(dataset), lastmod: dataset.updated_at
    dataset.datatables.each do |datatable|
      add datatable_path(datatable), :lastmod => datatable.updated_at
    end
  end
  add people_path, :priority => 0.7
  Person.find_each do |person|
    add person_path(person), :lastmod => person.updated_at
  end
  add citations_path :priority => 0.7
  website.citations.each do |citation|
    add citation_path(citation), :lastmod => citation.updated_at
  end
  add protocols_path, :priority => 0.7
  website.protocols.each do |protocol|
    add protocol_path(protocol), :lastmod => protocol.updated_on
  end
end
