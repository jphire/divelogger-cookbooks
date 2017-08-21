default['env'] = 'development'

default['divelogger'] = {}
default['divelogger']['settings'].tap do |conf|
  conf['region'] =  'eu-west-1'
  conf['username'] = 'vagrant'
end
