module Supermarket
  # Helper methods we'll mix into the Chef DSL
  module DSL
    def combined_mode?
      node['supermarket']['topology'] == 'combined'
    end

    def standalone_mode?
      node['supermarket']['topology'] == 'standalone'
    end

    def service_enabled?(service)
      node['supermarket'][service]['enable'] == true
    end
  end
end

Chef::Recipe.send(:include, Supermarket::DSL)
Chef::Provider.send(:include, Supermarket::DSL)
Chef::Resource.send(:include, Supermarket::DSL)
Chef::ResourceDefinition.send(:include, Supermarket::DSL)
