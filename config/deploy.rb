# frozen_string_literal: true

set :application, 'metadata'
set :repo_url, 'git@github.com:kf8a/metadata.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/u/apps/metadata'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true
#
# set :ssh_options, { forward_agent: true }

#
# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'public/uploads' #, 'config/unicorn'

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/site_keys.rb',
  'config/secret_token.rb', 'config/storage.yml', 'config/master.key'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 50

set :keep_assets, 2

set :puma_init_active_record, true

set :pty, true

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

before 'deploy:assets:precompile', 'deploy:yarn_install'
# after 'deploy:assets:precompile', 'assets:update_asset_server'

after 'deploy:updated', :create_nav
after 'deploy:updated', :update_asset_server
after 'deploy', 'thinking_sphinx:configure'
after 'deploy', 'thinking_sphinx:index'
after 'deploy', 'thinking_sphinx:start'

before 'deploy:updated', 'thinking_sphinx:stop'

namespace :deploy do
  desc 'Run rake yarn install'
  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && yarn install --silent --no-progress --no-audit --no-optional")
      end
    end
  end
end

desc 'Precompile assets on local machine and upload them to the server.'
task :update_asset_server do
  run_locally do
    execute 'rake assets:clobber'
    execute 'RAILS_ENV=production rake assets:precompile'
    # run "cd #{current_path} && bundle exec rake assets:precompile RAILS_ENV=production"
    # find_servers_for_task(current_task).each do |_server|
    execute "rsync -vr --exclude='.DS_Store' public/assets gprpc32.kbs.msu.edu:/var/www/lter/metadata-assets/"
  end
end

task :create_nav do
  on roles(:app) do
    execute "curl https://lter.kbs.msu.edu/export/nav/ -k -o #{release_path}/app/views/shared/_nav.html.erb -s"
    execute "curl https://lter.kbs.msu.edu/export/footer/ -k -o #{release_path}/app/views/shared/_footer.html.erb -s"
    execute "curl https://lter.kbs.msu.edu/export/header/ -k -o #{release_path}/app/views/shared/_header.html.erb -s"
    execute %(cd #{release_path}/app/views/shared; sed -i 's/src="http:/src="https:/g' _footer.html.erb)
    execute %(cd #{release_path}/app/views/shared; sed -i 's/src="http:/src="https:/g' _header.html.erb)
  end
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
  on roles(:app) do
    execute "cd #{current_path};bundle exec rake scores:update_date_range RAILS_ENV=production"
  end
end

desc 'update sitemap'
task :update_sitemap do
  run "cd #{current_path};bundle exec rake sitemap:create RAILS_ENV=production"
  run_locally "scp #{user}@#{server.host}:#{current_path}/public/sitemap.xml.gz ."
  run_locally "scp sitemap.xml.gz #{asset_host}:#{asset_path}/rails-sitemap.xml.gz"
  # run "cd #{current_path};bundle exec rake sitemap:refresh RAILS_ENV=production"
end
