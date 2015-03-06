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

return unless combined_mode?

unless File.exist?('/etc/opscode/chef-server-running.json')
  msg = "Supermarket is configured in 'combined mode' but a configured"
  msg << ' standalone Chef Server cannot be found.  Defaulting to a regular'
  msg << ' Supermarket install'
  Chef::Log.warn(msg)

  node.set['supermarket']['topology'] = 'standalone'
  return
end

private_chef = Chef::JSONCompat.from_json(
  IO.read('/etc/opscode/chef-server-running.json')
)
node.consume_attributes('private_chef' => private_chef['private_chef'])

unless node['private_chef']['topology'] == 'standalone'
  msg = "Running Supermarket in 'combined' mode is only available on"
  msg << 'Standalone Chef Servers'
  Chef::Application.fatal!(msg)
end

node.set['chef_server_url'] = node['fqdn']

# Configure combined postgresql
chef_pg = node['private_chef']['postgresql']
node.set['supermarket']['postgresql']['username'] = chef_pg['username']
node.set['supermarket']['database']['host'] = chef_pg['listen_address']
node.set['supermarket']['database']['port'] = chef_pg['port']
unless node['supermarket']['database']['password']
  require 'securerandom'
  node.set['supermarket']['database']['password'] = SecureRandom.hex(50)
end

# Configure combined nginx
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
