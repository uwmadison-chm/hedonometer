namespace :puma do
  desc "restart puma"
  task :restart do
    on roles(:app) do
      execute "systemctl show hedonometer_puma.service --property=MainPID | sed 's/^.*=//' | xargs kill -USR2"
    end
  end
end

after :finishing, "puma:restart"
