# frozen_string_literal: true

namespace :citation do
  desc 'load ris citation file'
  task :load, [:file] => [:environment] do |_t, args|
    pdf_folder = ENV.fetch("PDF_FOLDER", nil)
    Citation.from_ris("@import #{args[:file]}", pdf_folder)
  end
end
