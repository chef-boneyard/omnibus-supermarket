#
# Cookbook Name:: supermarket
# Recipe:: combined_mode
#
# Copyright 2015 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'omnibus-supermarket::config'

return unless combined_mode?

running_json = '/etc/opscode/chef-server-running.json'

unless File.exist?(running_json)
  msg = "Supermarket is configured in 'combined mode' but a configured"
  msg << ' standalone Chef Server cannot be found.  Defaulting to a regular'
  msg << ' Supermarket install'
  Chef::Log.warn(msg)

  node.set['supermarket']['topology'] = 'standalone'
  return
end

# Load Chef Server attributes
private_chef = Supermarket::Config.parse_json_file(running_json)
node.consume_attributes('private_chef' => private_chef['private_chef'])

unless node['private_chef']['topology'] == 'standalone'
  msg = "Running Supermarket in 'combined' mode is only available on"
  msg << 'Standalone Chef Servers'
  Chef::Application.fatal!(msg)
end

# Authorize oc-id
node.set['supermarket']['chef_server_url'] = "https://#{node['fqdn']}"
callback = "#{node['supermarket']['chef_server_url']}/auth/chef_oauth2/callback"

# Create the config during compile time because we need the id and secret
oc_id_application 'supermarket' do
  redirect_uri callback
  action :nothing
end.run_action(:create)

# Configure oc-id
oauth2 = Supermarket::Config.oauth2_config_for('supermarket')
node.set['supermarket']['chef_oauth2_app_id'] = oauth2['uid']
node.set['supermarket']['chef_oauth2_secret'] = oauth2['secret']
node.set['supermarket']['chef_oauth2_url'] = callback
unless node['supermarket']['ssl']['certificate']
  node.set['supermarket']['chef_oauth2_verify_ssl'] = false
end

# Configure postgresql
chef_pg = node['private_chef']['postgresql']
node.set['supermarket']['postgresql']['username'] = chef_pg['username']
node.set['supermarket']['database']['host'] = chef_pg['listen_address']
node.set['supermarket']['database']['port'] = chef_pg['port']
unless node['supermarket']['database']['password']
  require 'securerandom'
  node.set['supermarket']['database']['password'] = SecureRandom.hex(50)
end

# Configure nginx
chef_nginx = node['private_chef']['nginx']
chef_user = node['private_chef']['user']['username']

node.set['supermarket']['nginx']['directory'] = "#{chef_nginx['dir']}/etc"
node.set['supermarket']['nginx']['log_directory'] = chef_nginx['log_directory']
node.set['supermarket']['nginx']['user'] = chef_user
node.set['supermarket']['nginx']['group'] = chef_user

# Disable unused services
%w(redis nginx postgresql).each do |service|
  node.set['supermarket'][service]['enable'] = false
end
