namespace :delayed_job do
  desc "restart delayed_job"
  task :restart do
    on roles(:app) do
      execute "systemctl show hedonometer_delayed_job.service --property=MainPID | sed 's/^.*=//' | xargs kill -TERM"
    end
  end
end

