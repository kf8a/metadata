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

# app/jobs/site_search_sync_job.rb
class SiteSearchSyncJob < ApplicationJob
  retry_on StandardError, wait: 30.seconds, attempts: 5

  def perform(model_name, id)
    model  = model_name.constantize
    record = model.find_by(id: id)
    if record&.search_indexable?
      SiteSearch.upsert(record.search_document)
    else
      SiteSearch.remove(model.search_id_for(id)) # deleted or unpublished
    end
  end
end
