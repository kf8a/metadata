require 'polyglot'

namespace :citation do
  desc 'load ris citation file'
  task :load, [:file] => [:environment] do |t, args|
    pdf_folder = ENV["PDF_FOLDER"]
    Citation.from_ris("@import #{args[:file]}", pdf_folder)
  end
end
