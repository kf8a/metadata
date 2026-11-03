# frozen_string_literal: true

# support for keeping the search index updated
module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search_id_for(id)
      "rails-#{model_name.singular}-#{id}"
    end
  end

  included do
    after_commit(on: %i[create update destroy]) { SiteSearchSyncJob.perform_later(self.class.name, id) }
  end

  def search_id
    self.class.search_id_for(id)
  end

  def search_indexable?
    true
  end

  def lter_site?
    name = search_website_name
    name.blank? || name == 'lter'
  end

  def search_website_name
    nil
  end
end
