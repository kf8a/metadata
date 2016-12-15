desc 'Run all tests and specs, but not features'
task multi: 'multi:no_cuke'

namespace :multi do
  desc 'Run all tests and specs, but not features'
  task :no_cuke do
    Rake::Task['test'].invoke
    Rake::Task['spec'].invoke
  end

  desc 'Run all tests, specs, and features'
  task :cuke do
    Rake::Task['test'].invoke
    Rake::Task['spec'].invoke
    Rake::Task['cucumber'].invoke
  end

  desc 'Run controller tests/specs'
  task :controllers do
    Rake::Task['test:functionals'].invoke
    Rake::Task['spec:controllers'].invoke
  end

  desc 'Run models tests/specs'
  task :models do
    Rake::Task['test:units'].invoke
    Rake::Task['spec:models'].invoke
  end

  #Example: rake multi:single[datatable]
  desc "Runs a specific item's tests/specs; rake multi:single[datatables_c]"
  task :single, :item_name do |t, args|
    item_name = args.item_name
    Rake::Task["test:#{item_name}"].invoke
    Rake::Task["spec:#{item_name}"].invoke
  end
end
