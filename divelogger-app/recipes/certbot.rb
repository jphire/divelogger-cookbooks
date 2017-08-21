
include_recipe 'certbot'

certbot_certonly_webroot 'something' do
  webroot_path '/srv/www/divelogger'
  email 'janne@divelogger.org'
  domains ['divelogger.org']
  agree_tos true
end
