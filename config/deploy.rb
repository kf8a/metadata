require 'bundler/capistrano'
# require 'new_relic/recipes'
require 'thinking_sphinx/capistrano'

set :application, 'metadata'

set :scm, :git
set :repository, 'git@github.com:kf8a/metadata.git'

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/u/apps/#{application}"

set :user, 'deploy'
set :use_sudo, false

set :branch, 'master'
set :deploy_via, :remote_cache

set :keep_releases, 20

ssh_options[:forward_agent] = true

set :unicorn_binary, 'unicorn'
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, '/var/u/apps/metadata/shared/pids/unicorn.pid'

def remote_file_exists?(full_path)
  'true' == capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

before :deploy do
  unless exists?(:host)
    raise 'Please invoke me like `cap stage deploy` where stage is production/staging'
  end
end

namespace :deploy do
  desc "start unicorn appserves remote_file_exists?('/dev/null')"
  task :start, roles: :app, except: { no_release: true } do
    run "cd #{current_path} && bundle exec  #{unicorn_binary}  -c #{unicorn_config} --env  #{rails_env} -D"
  end
  desc 'stop unicorn appserver'
  task :stop, roles: :app, except: { no_release: true } do
    run "#{try_sudo} kill `cat #{unicorn_pid}`"
  end
  desc 'gracefully stop unicorn appserver'
  task :graceful_stop, roles: :app, except: { no_release: true } do
    run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`" if remote_file_exists?(unicorn_pid)
  end
  desc 'reload unicorn appserver'
  task :reload, roles: :app, except: { no_release: true } do
    run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
  end
  desc 'restart unicorn appserver'
  task :restart, roles: :app, except: { no_release: true } do
    stop
    sleep(2) # to allow the unicorn to die
    start
  end

  after 'deploy:finalize_update', :create_nav
  after 'deploy:finalize_update', :link_production_db
  after 'deploy:finalize_update', :link_unicorn
  after 'deploy:finalize_update', :link_site_keys
  # after 'deploy:finalize_update', :link_new_relic
  after 'deploy:finalize_update', :link_s3
  after 'deploy', 'thinking_sphinx:rebuild'

  # after 'deploy', :lock_sphinks

  before 'deploy:update_code', 'thinking_sphinx:stop'
  after 'deploy:finalize_update', 'thinking_sphinx:start'
  after 'deploy:finalize_update', 'sphinx:symlink_indexes'

  # namespace :assets do
  #   desc 'Precompile assets on local machine and upload them to the server.'
  #   task :precompile, roles: :web, except: { no_release: true } do
  #     run_locally 'bundle exec rake assets:clobber'
  #     run_locally 'bundle exec rake assets:precompile RAILS_ENV=production'
  #     # run "cd #{current_path} && bundle exec rake assets:precompile RAILS_ENV=production"
  #     find_servers_for_task(current_task).each do |_server|
  #       run_locally "rsync -vr --exclude='.DS_Store' public/assets gprpc24.kbs.msu.edu:/var/www/lter/metadata-assets/"
  #     end
  #   end
  # end

  desc 'upload configs'
  task :upload_configs do
    run "mkdir -p #{shared_path}/config"
  end
end

task :oshtemo do
  set :host, 'oshtemo.kbs.msu.edu'
  set :asset_host, 'gprpc24.kbs.msu.edu'
  set :asset_path, '/var/www/lter/metadata-assets'
  role :web, host.to_s
  role :app, host.to_s
  role :db, host.to_s, primary: true
end

task :kalkaska do
  set :host, 'kalkaska.css.msu.edu'
  set :asset_host, 'gprpc24.kbs.msu.edu'
  set :asset_path, '/var/www/lter/metadata-assets'
  role :web, host.to_s
  role :app, host.to_s
  role :db, host.to_s, primary: true
end

task :staging do
  set :host, 'houghton.kbs.msu.edu'
  set :asset_host, 'gprpc24.kbs.msu.edu'
  set :asset_path, '/var/www/lter/metadata-assets'
  set :public_asset_host, 'lter.kbs.msu.edu'
  role :web, host.to_s
  role :app, host.to_s
  role :db, host.to_s, primary: true
end

namespace :sphinx do
  desc 'Symlink Sphinx indexes'
  task :symlink_indexes, roles: [:app] do
    run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
  end
end

task :lock_sphinks do
  run "cd #{current_path};chmod go-r config/production.sphinx.conf"
end

task :create_nav do
  run "curl https://lter.kbs.msu.edu/export/nav/ -o #{release_path}/app/views/shared/_nav.html.erb -s"
  run "curl https://lter.kbs.msu.edu/export/footer/ -o #{release_path}/app/views/shared/_footer.html.erb -s"
  run "curl https://lter.kbs.msu.edu/export/header/ -o #{release_path}/app/views/shared/_header.html.erb -s"
  run %(cd #{release_path}/app/views/shared; sed -i 's/src="http:/src="https:/g' _footer.html.erb)
  run %(cd #{release_path}/app/views/shared; sed -i 's/src="http:/src="https:/g' _header.html.erb)
end

desc 'Link in the production database.yml'
task :link_production_db do
  run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
end

desc 'Link in the site_keys.rb file'
task :link_site_keys do
  run "ln -nfs #{deploy_to}/shared/config/site_keys.rb #{release_path}/config/initializers/site_keys.rb"
  run "ln -nfs #{deploy_to}/shared/config/secret_token.rb #{release_path}/config/initializers/secret_token.rb"
end

# desc 'Link in the new relic monitoring'
# task :link_new_relic do
#   run "ln -nfs #{deploy_to}/shared/config/newrelic.yml #{release_path}/config/newrelic.yml"
# end

desc 'Link in the s3 credentials'
task :link_s3 do
  # run "ln -nfs #{deploy_to}/shared/config/s3.yml #{release_path}/config/s3.yml"
  run "ln -nfs #{deploy_to}/shared/config/storage.yml #{release_path}/config/storage.yml"
end

desc 'link unicorn.rb'
task :link_unicorn do
  # run "ln -nfs /etc/unicorn/#{application} #{release_path}/config/unicorn.rb"
  run "ln -nfs #{deploy_to}/shared/config/unicorn.rb #{release_path}/config/unicorn.rb"
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

desc 'update date ranges'
task :update_date_range do
  run "cd #{current_path};bundle exec rake scores:update_date_range RAILS_ENV=production"
end

desc 'update sitemap'
task :update_sitemap do
  run "cd #{current_path};bundle exec rake sitemap:create RAILS_ENV=production"
  run_locally "scp #{user}@#{server.host}:#{current_path}/public/sitemap.xml.gz ."
  run_locally "scp sitemap.xml.gz #{asset_host}:#{asset_path}/rails-sitemap.xml.gz"
  # run "cd #{current_path};bundle exec rake sitemap:refresh RAILS_ENV=production"
end
