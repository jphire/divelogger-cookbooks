module Helper
  module Utils
    # Return application settings by environment
    def self.get_settings(env, default_settings)
      settings = default_settings
      if env == 'development'
        Chef::Search::Query.new.search(:settings, 'id:env') do |conf|
          settings['access_key_id'] = conf['access_key_id']
          settings['secret_access_key'] = conf['secret_access_key']
        end
      else
        # Search from aws data bags
        Chef::Search::Query.new.search(:aws_opsworks_stack) do |conf|
          settings['access_key_id'] = conf['custom_cookbooks_source']['username']
          settings['secret_access_key'] = conf['custom_cookbooks_source']['password']
        end
      end
      return settings
    end
  end
end

