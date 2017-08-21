module Helper
  module Utils
    # Return application settings by environment
    def self.get_settings
      Chef::Search::Query.new.search(:settings, 'id:env') do |settings|
        # settings = search(:settings, "id:env").first
        if settings.include? 'env'
          Chef::Log.info("********** ENVIRONMENT: '#{settings['env']}' **********")
          return settings
        else
          # Search from aws data bags
          Chef::Search::Query.new.search("aws_opsworks_app") do |settings|
            if settings.include? 'env'
              return settings
            else
              Chef::Log.info("********** ENVIRONMENT: Not found **********")
              raise "Cannot find environment info, aborting.."
            end
          end
        end
      end
    end
  end
end

