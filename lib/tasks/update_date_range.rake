# frozen_string_literal: true

namespace :scores do
  desc 'update datatable date ranges'
  task update_date_range: :environment do
    Datatable.where('id > 572').order(:id).all.each do |table|
      next if table.deprecated_in_favor_of
      next if table.id == 87
      next if table.id == 263
      next if table.id == 280
      p table.id
      table.update_temporal_extent
      table.save
    end
  end
end
