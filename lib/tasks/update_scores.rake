namespace :scores do
  desc 'update datatable scores'
  task :update => :environment do
    ScoreCard.update_all
  end
end
