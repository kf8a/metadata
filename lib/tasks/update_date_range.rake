# frozen_string_literal: true

namespace :scores do
  desc 'update datatable date ranges'
  task update_date_range: :environment do
    Datatable.each do |table|
      table.update_temporal_extent
      table.save
    end
  end
end
