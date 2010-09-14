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

set :branch, $1 if `git branch` =~ /\* (\S+)\s/m
set :deploy_via, :copy
#set :git_enable_submodules,1

before :deploy do
  unless exists?(:host)
    raise "Please invoke me like `cap stage deploy` where stage is production/staging"
  end
end

namespace :deploy do
  namespace :thin do
    [:stop, :start, :restart].each do |t|
      desc "#{t.to_s.capitalize} the thin appserver"
      task t, :roles => :app do
        invoke_command "thin -C /etc/thin/metadata.yml #{t.to_s}"
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
  
 # after :deploy, :link_paperclip_storage, 
  after 'deploy:symlink', :link_production_db
  after 'deploy:symlink', :link_site_keys
  after 'deploy:symlink', :link_new_relic
  after 'deploy:symlink', :update_spinks
  after 'deploy:symlink', :link_assets
end

task :staging do 
  set :host, 'sebewa'
  
  role :app, "#{host}.kbs.msu.edu"
  role :web, "#{host}.kbs.msu.edu"
  role :db,  "#{host}.kbs.msu.edu", :primary => true
end

task :production do 
  set :host, 'houghton'
  
  role :app, "#{host}.kbs.msu.edu"
  role :web, "#{host}.kbs.msu.edu"
  role :db,  "#{host}.kbs.msu.edu", :primary => true
  
  after 'deploy:symlink', :set_subdomain_tdl
end

desc 'Update sphinks'
task :update_spinks do
  run "cd #{release_path};rake ts:stop RAILS_ENV=production"
  run "cd #{release_path};rake ts:index RAILS_ENV=production"
  run "cd #{release_path};rake ts:start RAILS_ENV=production"
  
end

desc "Link in the production database.yml"
task :link_production_db do
  run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
end

desc "Link in the site_keys.rb file"
task :link_site_keys do
  run "ln -nfs #{deploy_to}/shared/config/site_keys.rb #{release_path}/config/initializers/site_keys.rb"
end

desc "Link in the new relic monitoring"
task :link_new_relic do
  run "ln -nfs #{deploy_to}/shared/config/newrelic.yml #{release_path}/config/newrelic.yml"
end

desc 'set subdomain tdl'
task :set_subdomain_tdl do
  run "sed -i 's/production => 3/production => 2/' #{release_path}/config/environment.rb"
end

desc 'link asset directory'
task :link_assets do
  run "ln -nfs #{deploy_to}/shared/assets #{release_path}"
end

# task :link_paperclip_storage, :roles => :app do
#   %w{publications}.each do |share|
#     run "rm -rf #{release_path}/public/#{share}"
#     run "mkdir -p #{shared_path}/system/#{share}"
#     run "ln -nfs #{shared_path}/system/#{share} #{release_path}/public/#{share}"
#   end
# end
