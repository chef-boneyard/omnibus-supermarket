require 'chefspec'
require 'chefspec/berkshelf'
require_relative 'support/matchers'

RSpec.configure do |config|
  config.log_level = :fatal
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end

def stub_combined_config
  stub_chef_server_config
  stub_supermarket_config
  stub_supermarket_oauth2
end

def stub_chef_server_config
  allow(File).to receive(:exist?).and_call_original
  allow(File)
    .to receive(:exist?)
    .with('/etc/opscode/chef-server-running.json')
    .and_return(true)

  allow(IO).to receive(:read).and_call_original
  allow(IO)
    .to receive(:read)
    .with('/etc/opscode/chef-server-running.json')
    .and_return(
      File.read(
        File.expand_path('../fixtures/chef-server-running.json', __FILE__)
      )
    )
end

def stub_supermarket_config
  allow(Supermarket::Config)
    .to receive(:from_files).and_return({'topology' => 'combined'})
end

def stub_supermarket_oauth2
  allow(Supermarket::Config)
    .to receive(:oauth2_config_for).and_return(supermarket_oc_id_config)
end

def supermarket_oc_id_config
  {
    'name' => 'supermarket',
    'uid' => '8b6ff4d565f64c91e317a02deb84d992b6fa54c4ebe691b731598a73339edae2',
    'secret' => 'd030b0dee43b47de0492c42f5dbd94f82b00d913ca87a2f0c78ab93c1fd23fff',
    'redirect_uri' => 'https://supermarket/'
  }
end
