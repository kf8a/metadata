require "bundler/capistrano"
#require 'new_relic/recipes'
require 'thinking_sphinx/capistrano'

set :application, "metadata"

#set :repository,  "/Users/bohms/code/metadata"
set :scm, :git
set :repository, "git@github.com:kf8a/metadata.git"


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/var/u/apps/#{application}"

set :user, 'deploy'
set :use_sudo, false

#set :branch, $1 if `git branch` =~ /\* (\S+)\s/m
set :branch, "master"
set :deploy_via, :remote_cache

ssh_options[:forward_agent] = true

set :unicorn_binary, "unicorn"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "/var/u/apps/metadata/shared/pids/unicorn.pid"

def remote_file_exists?(full_path)
    'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

before :deploy do
  unless exists?(:host)
    raise "Please invoke me like `cap stage deploy` where stage is production/staging"
  end
end

namespace :deploy do
  desc "start unicorn appserves remote_file_exists?('/dev/null')"
  task :start, :roles => :app, :except => { :no_release => true } do 
    run "cd #{current_path} && bundle exec  #{unicorn_binary}  -c #{unicorn_config} --env  #{rails_env} -D"
  end
  desc "stop unicorn appserver"
  task :stop, :roles => :app, :except => { :no_release => true } do 
    run "#{try_sudo} kill `cat #{unicorn_pid}`"
  end
  desc "gracefully stop unicorn appserver"
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    if remote_file_exists?(unicorn_pid) 
      run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
    end
  end
  desc "reload unicorn appserver"
  task :reload, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
  end
  desc "restart unicorn appserver"
  task :restart, :roles => :app, :except => { :no_release => true } do
   # update_nav
    stop
    sleep(2)  # to allow the unicorn to die
    start
  end

  after 'deploy:finalize_update', :create_nav
  after 'deploy:finalize_update', :link_production_db
  after 'deploy:finalize_update', :link_unicorn
  after 'deploy:finalize_update', :link_site_keys
  after 'deploy:finalize_update', :link_new_relic
  after 'deploy:finalize_update', :link_s3
  #after 'deploy', :lock_sphinks

  namespace :assets do
    desc "Precompile assets on local machine and upload them to the server."
    task :precompile, :roles => :web, except: {no_release: true} do
      run_locally "bundle exec rake assets:clean"
      run_locally "bundle exec rake assets:precompile"
      find_servers_for_task(current_task).each do |server|
        run_locally "rsync -vr --exclude='.DS_Store' public/assets #{user}@#{server.host}:#{shared_path}/"
        run_locally "rsync -vr --exclude='.DS_Store' public/assets #{asset_host}:#{asset_path}/"
      end
    end
  end

end

task :master do

  set :host, 'gprpc28'

  role :app, "#{host}.kbs.msu.edu"
  role :web, "#{host}.kbs.msu.edu"
  role :db,  "#{host}.kbs.msu.edu", :primary=>true

#  after 'deploy:symlink', :set_asset_host
end

task :oshtemo do
  set :host, 'oshtemo.kbs.msu.edu'
  set :asset_host, 'hillsdale.kbs.msu.edu'
  set :asset_path, '/var/www/lter/metadata-assets'
  role :web, "#{host}"
  role :app, "#{host}"
  role :db, "#{host}", :primary => true
end

task :kalkaska do
  set :host, 'kalkaska.css.msu.edu'
  set :asset_host, 'hillsdale.kbs.msu.edu'
  set :asset_path, '/var/www/lter/metadata-assets'
  role :web, "#{host}"
  role :app, "#{host}"
  role :db, "#{host}", :primary => true
end

#before 'deploy:update_code', 'thinking_sphinx:stop'
#after 'deploy:update_code', 'thinking_sphinx:start'

namespace :sphinx do
  desc "Symlink Sphinx indexes"
  task :symlink_indexes, :roles => [:app] do
    run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
  end
end

after 'deploy:finalize_update', 'sphinx:symlink_indexes'

task :lock_sphinks do
   run "cd #{current_path};chmod go-r config/production.sphinx.conf"
end


desc 'update menus, headers and footers'
task :update_nav do
  run "cd #{current_path}/public;curl http://lter.kbs.msu.edu/export/nav/ -o nav.html -s"
  run "cd #{current_path}/public;curl http://lter.kbs.msu.edu/export/footer/ -o footer.html -s"
  run "cd #{current_path}/public;curl http://lter.kbs.msu.edu/export/header/ -o header.html -s"
end
task :create_nav do
  run "cd #{release_path}/public;curl http://lter.kbs.msu.edu/export/nav/ -o nav.html -s"
  run "cd #{release_path}/public;curl http://lter.kbs.msu.edu/export/footer/ -o footer.html -s"
  run "cd #{release_path}/public;curl http://lter.kbs.msu.edu/export/header/ -o header.html -s"
end

desc "Link in the production database.yml"
task :link_production_db do
  run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
end

desc "Link in the site_keys.rb file"
task :link_site_keys do
  run "ln -nfs #{deploy_to}/shared/config/site_keys.rb #{release_path}/config/initializers/site_keys.rb"
  run "ln -nfs #{deploy_to}/shared/config/secret_token.rb #{release_path}/config/initializers/secret_token.rb"
end

desc "Link in the new relic monitoring"
task :link_new_relic do
  run "ln -nfs #{deploy_to}/shared/config/newrelic.yml #{release_path}/config/newrelic.yml"
end

desc "Link in the s3 credentials"
task :link_s3 do
  run "ln -nfs #{deploy_to}/shared/config/s3.yml #{release_path}/config/s3.yml"
end

desc "link unicorn.rb"
task :link_unicorn do
  # run "ln -nfs /etc/unicorn/#{application} #{release_path}/config/unicorn.rb"
  run "ln -nfs #{deploy_to}/shared/config/unicorn.rb #{release_path}/config/unicorn.rb"
end

desc 'set asset host on production'
task :set_asset_host do
  run "sed -i 's/#config.action_controller.asset_host/config.action_controller.asset_host/' #{release_path}/config/environments/production.rb"
end

desc 'link asset directory'
task :link_assets do
  run "ln -nfs #{deploy_to}/shared/assets #{release_path}"
end

desc 'push secrets'
task :push_secrets do
  find_servers_for_task(current_task).each do |server|
    run_locally "rsync -vr --exclude='.DS_Store' shared/config #{user}@#{server.host}:#{shared_path}"
  end
end

desc 'update scores'
task :update_scores do
  run "cd #{current_path};bundle exec rake scores:update RAILS_ENV=production"
end

desc 'update sitemap'
task :update_sitemap do
  run "cd #{current_path};bundle exec rake sitemap:create RAILS_ENV=production"
  run_locally "scp #{user}@#{server.host}:#{current_path}/public/sitemap.xml.gz ."
  run_locally "scp sitemap.xml.gz #{asset_host}:#{asset_path}/rails-sitemap.xml.gz"
  # run "cd #{current_path};bundle exec rake sitemap:refresh RAILS_ENV=production"
end
