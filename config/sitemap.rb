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
  add datatables_path, :priority => 0.9, :changefreq => 'daily'
  Datatable.find_each do |datatable|
      # next unless datatable.dataset.website.name == 'lter'
      add datatable_path(datatable), :lastmod => datatable.updated_at
  end
  add people_path, :priority => 0.7
  Person.find_each do |person|
    add person_path(person) #, :lastmod => person.updated_at
  end
  add citations_path :priority => 0.7
  Citation.find_each do |citation|
    add citation_path(citation), :lastmod => citation.updated_at
  end
  add protocols_path, :priority => 0.7
  Protocol.find_each do |protocol|
    add protocol_path(protocol) #, :lastmod => protocol.updated_at
  end
end
