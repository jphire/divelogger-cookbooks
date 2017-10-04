bash 'restart-monit' do
  cwd '/srv/www'
  user 'root'
  code <<-EOH
    monit stop all;
    monit start all;
  EOH
end
