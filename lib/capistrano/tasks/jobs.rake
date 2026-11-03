# frozen_string_literal: true

# Restarts the Solid Queue job process (bin/jobs) on every deploy, so it runs the new code.
# It is a systemd service named like the Puma one (metadata_jobs_production; see
# config/metadata_jobs_production.service.example) and uses the same systemctl settings as
# capistrano3-puma: a user service unless :puma_systemctl_user is :system.
namespace :jobs do
  jobs_unit = -> { fetch(:jobs_service_unit_name, "#{fetch(:application)}_jobs_#{fetch(:stage)}") }
  user_service = -> { fetch(:puma_systemctl_user, :user) != :system }
  systemctl = lambda do |*args|
    [fetch(:puma_systemctl_bin, '/bin/systemctl'), *('--user' if user_service.call), *args]
  end

  desc 'Restart the background job process'
  task :restart do
    on roles(:app) do
      if test(*systemctl.call('cat', jobs_unit.call))
        if user_service.call
          execute(*systemctl.call('restart', jobs_unit.call))
        else
          sudo(*systemctl.call('restart', jobs_unit.call))
        end
      else
        # First deploy after Solid Queue was added, before the unit is installed
        warn "#{jobs_unit.call} is not installed on #{host}; jobs are not being processed. " \
             'Install config/metadata_jobs_production.service.example (see its header).'
      end
    end
  end
end

after 'deploy:published', 'jobs:restart'
