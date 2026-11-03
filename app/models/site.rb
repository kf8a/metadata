# frozen_string_literal: true

# The two sites this app serves. Requests are told apart by host (ApplicationController#subdomain_from_request);
# emails link back to the site they were sent from.
module Site
  HOSTS = { 'glbrc' => 'data.sustainability.glbrc.org', 'lter' => 'lter.kbs.msu.edu' }.freeze

  # Anything else, including a site not recorded, goes to LTER
  def self.host(name)
    HOSTS.fetch(name.to_s, HOSTS['lter'])
  end
end
