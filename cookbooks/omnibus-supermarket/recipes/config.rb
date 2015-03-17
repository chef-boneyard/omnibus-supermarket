#
# Cookbook Name:: supermarket
# Recipe:: config
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
config_file = "#{node['supermarket']['config_directory']}/supermarket.rb"
secrets_file = "#{node['supermarket']['config_directory']}/secrets.json"

begin
  attributes = Supermarket::Config.from_files(config_file, secrets_file)
rescue Errno::ENOENT
  Chef::Log.debug("Missing #{config_file}. Skipping.")
rescue NoMethodError
  Chef::Log.fatal("Invalid attributes in #{config_file}")
  raise
ensure
  node.consume_attributes('supermarket' => attributes)
end

include_recipe 'omnibus-supermarket::combined_mode' if combined_mode?

# Copy things we need from the supermarket namespace to the top level. This is
# necessary for some community cookbooks.
node.consume_attributes('nginx' => node['supermarket']['nginx'],
                        'runit' => node['supermarket']['runit'])

# set chef_oauth2_url from chef_server_url after this value has been loaded
# from config
if node['supermarket']['chef_server_url'] && node['supermarket']['chef_oauth2_url'].nil?
  node.set['supermarket']['chef_oauth2_url'] = node['supermarket']['chef_server_url']
end

user node['supermarket']['user']

group node['supermarket']['group'] do
  members [node['supermarket']['user']]
end

directory node['supermarket']['config_directory'] do
  owner node['supermarket']['user']
  group node['supermarket']['group']
end

directory node['supermarket']['var_directory'] do
  owner node['supermarket']['user']
  group node['supermarket']['group']
  mode '0700'
end

directory "#{node['supermarket']['var_directory']}/etc" do
  owner node['supermarket']['user']
  group node['supermarket']['group']
  mode '0700'
end

file config_file do
  owner node['supermarket']['user']
  group node['supermarket']['group']
  mode '0600'
end

file secrets_file do
  content Supermarket::Config.secrets_to_json(node)
  owner node['supermarket']['user']
  group node['supermarket']['group']
  mode '0600'
end
