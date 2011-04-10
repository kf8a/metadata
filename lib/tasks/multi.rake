desc "Run all tests and specs, but not features"
task :multi => 'multi:no_cuke'

namespace :multi do
  desc "Run all tests and specs, but not features"
  task :no_cuke do
    Rake::Task['test'].invoke
    Rake::Task['spec'].invoke
  end

  desc "Run all tests, specs, and features"
  task :cuke do
    Rake::Task['test'].invoke
    Rake::Task['spec'].invoke
    Rake::Task['cucumber'].invoke
  end
end