set :application, "metadata"
set :repository,  "/Users/bohms/code/metadata"
set :scm, :git

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/var/u/apps/#{application}"

set :user, 'deploy'
set :use_sudo, false

set :branch, "searching"
set :deploy_via, :copy
#set :git_enable_submodules,1


role :app, 'houghton.kbs.msu.edu'
role :web, 'houghton.kbs.msu.edu'
role :db,  'houghton.kbs.msu.edu', :primary => true

namespace :deploy do
  namespace :thin do
    [:stop, :start, :restart].each do |t|
      desc "#{t.to_s.capitalize} the thin appserver"
      task t, :roles => :app do
        invoke_command "thin -C /etc/thin/metadata.yml #{t.to_s}"
      end
    end
   end
  namespace :mongrel do
    [ :stop, :start, :restart ].each do |t|
      desc "#{t.to_s.capitalize} the mongrel appserver"
      task t, :roles => :app do
        #invoke_command checks the use_sudo variable to determine how to run the mongrel_rails command
        invoke_command "mongrel_rails cluster::#{t.to_s} -C #{mongrel_conf}" #, :via => run_method
      end
    end
  end

  desc "Custom restart task for thin cluster"
  task :restart, :roles => :app, :except => { :no_release => true } do
    deploy.thin.restart
  end

  desc "Custom start task for thin cluster"
  task :start, :roles => :app do
    deploy.thin.start
  end

  desc "Custom stop task for thin cluster"
  task :stop, :roles => :app do
    deploy.thin.stop
  end
  
  after "deploy:update_code", :link_production_db
end

# database.yml task
desc "Link in the production database.yml"
task :link_production_db do
  run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
end

task :after_update_code, :roles => :app do
  %w{publications images}.each do |share|
    run "rm -rf #{release_path}/public/#{share}"
    run "mkdir -p #{shared_path}/system/#{share}"
    run "ln -nfs #{shared_path}/system/#{share} #{release_path}/public/#{share}"
  end
end
