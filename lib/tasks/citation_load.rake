require 'polyglot'

namespace :citation do
  desc 'load ris citation file'
  task :load, [:file] => [:environment] do |t, args|
    Citation.from_ris("@import #{args[:file]}")
  end
end
