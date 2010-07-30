require 'rcov/rcovtask'

namespace :rcov do
  desc 'Measures test coverage using rcov'
  Rcov::RcovTask.new(:test) do |rcov|
    rcov.pattern    = %w(test/unit/*_test.rb test/functional/*_test.rb test/integration/*_test.rb)
    rcov.output_dir = 'rcov'
    rcov.verbose    = true
    rcov.rcov_opts << '--exclude "gems/*"'
    rcov.rcov_opts << '--rails'
  end
end

#This runs with "rake rcov:test"
