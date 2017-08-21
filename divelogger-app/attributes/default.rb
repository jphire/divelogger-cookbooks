
default['env'] = 'development'

# Monit configuration attributes
default['monit']['config'].tap do |conf|

  # How often should monit poll
  conf['poll_freq'] = 60

  # configure a delay before beginning polling
  # allows for normal system startup
  conf['start_delay'] = 5

  conf['log_file'] = '/var/log/monit.log'
  conf['pid_file'] = '/var/run/monit.pid'


  # what port to bind to
  conf['port'] = 2812

  # what interface to bind to
  # binding to a public interface
  # will make the web ui accessible
  conf['listen'] = '127.0.0.1'

  # list of permitted control port accessors (host, basic-auth, pam, htpasswd)
  conf['allow'] = ['localhost']

  # mail system configuration
  conf['mail_from'] = "monit@#{node['fqdn'] || 'localhost'}"
  conf['mail_subject'] = '$SERVICE $EVENT at $DATE'
  conf['mail_message'] = <<-EOT
    Monit $ACTION $SERVICE at $DATE on $HOST: $DESCRIPTION.
    Yours sincerely,
    monit
  EOT
  conf['mail_servers'] = []

  # monit built-in configuration files path
  conf['built_in_config_path'] = '/etc/monit/monitrc.d'

  # what built-in configurations to load
  conf['built_in_configs'] = []
end

default['certbot']['sandbox']['webroot_path'] = '/srv/www'