# frozen_string_literal: true

# Keeps the site search index in step with a record (see Searchable)
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
