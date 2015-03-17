#
# Cookbook Name:: supermarket
# Recipe:: nginx
#
# Copyright 2014 Chef Software, Inc.
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

if combined_mode?
  sv_cmd = "#{node['private_chef']['install_path']}/embedded/bin/sv"

  runit_service 'nginx' do
    provider Chef::Provider::Service::Simple
    supports restart: true, status: true
    restart_command "#{sv_cmd} restart nginx"
    action :nothing
  end
elsif service_enabled?('nginx')
  [node['supermarket']['nginx']['cache']['directory'],
   node['supermarket']['nginx']['log_directory'],
   node['supermarket']['nginx']['directory'],
   "#{node['supermarket']['nginx']['directory']}/conf.d",
   "#{node['supermarket']['nginx']['directory']}/sites-enabled"].each do |dir|
    directory dir do
      owner node['supermarket']['nginx']['user']
      group node['supermarket']['nginx']['group']
      mode '0700'
      recursive true
    end
  end

  component_runit_service 'nginx' do
    package 'supermarket'
  end

  template "#{node['supermarket']['nginx']['directory']}/nginx.conf" do
    cookbook 'nginx'
    source 'nginx.conf.erb'
    owner node['supermarket']['nginx']['user']
    group node['supermarket']['nginx']['group']
    mode '0600'
    notifies :restart, 'runit_service[nginx]'
  end
end

if combined_mode? || service_enabled?('nginx')
  # Link the mime.types
  link "#{node['supermarket']['nginx']['directory']}/mime.types" do
    to "#{node['supermarket']['install_directory']}/embedded/conf/mime.types"
  end
else
  runit_service 'nginx' do
    action :disable
  end
end
