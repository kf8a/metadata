# frozen_string_literal: true

# Typesense client to send data to the typesense server
module SiteSearch
  ALIAS = 'site_pages'
  URL   = URI(ENV.fetch('TYPESENSE_URL', 'http://127.0.0.1:8108'))

  def self.client(timeout: 5)
    Typesense::Client.new(
      nodes: [{ host: URL.host, port: URL.port, protocol: URL.scheme }],
      api_key: Rails.application.credentials.dig(:typesense, :indexer_key),
      connection_timeout_seconds: timeout,
      num_retries: 2
    )
  end

  def self.upsert(doc)
    client.collections[ALIAS].documents.upsert(doc)
  end

  def self.remove(id)
    client.collections[ALIAS].documents[id].delete
  rescue Typesense::Error::ObjectNotFound
    nil
  end

  # Import always returns HTTP 200, so every per-document result must be checked.
  def self.bulk_upsert(docs, collection: ALIAS)
    results = client(timeout: 300).collections[collection].documents.import(docs, action: 'upsert')
    failures = results.reject { |r| r['success'] }
    raise "Typesense rejected #{failures.size} documents: #{failures.first(3)}" if failures.any?
  end
end
