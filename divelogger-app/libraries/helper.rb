module Helper
  module Utils
    # Return application settings by environment
    def self.get_settings(env, default_settings, external_settings, required_settings)
      settings = {}

      required_settings.each do |s|
        if external_settings.include? s
          settings[s] = external_settings[s]
        elsif default_settings.include? s
          settings[s] = default_settings[s]
        else
          raise "Could not find required setting: " + s
        end
      end

      if env == 'development'
        Chef::Search::Query.new.search(:settings, 'id:env') do |conf|
          settings['access_key_id'] = conf['access_key_id']
          settings['secret_access_key'] = conf['secret_access_key']
          settings['mongo_host'] = conf['mongo_host']
          settings['secretToken'] = conf['secretToken']
        end
      else
        # Search from aws data bags
        Chef::Search::Query.new.search(:aws_opsworks_stack) do |conf|
          settings['access_key_id'] = conf['custom_cookbooks_source']['username']
          settings['secret_access_key'] = conf['custom_cookbooks_source']['password']
        end

        Chef::Search::Query.new.search(:aws_opsworks_app) do |conf|
          settings['secretToken'] = conf['environment']['secretToken']
        end

        Chef::Search::Query.new.search(:aws_opsworks_instance) do |instance|
          instance['layer_ids'].each do |id|
            if id == external_settings['mongo_layer_id']
              settings['mongo_host'] = instance['private_ip']
            end
          end
        end
      end
      return settings
    end
  end
end

