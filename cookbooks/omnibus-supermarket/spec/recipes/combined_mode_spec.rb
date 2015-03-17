describe 'omnibus-supermarket::combined_mode' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.automatic['memory']['total'] = '16000MB'
    end.converge(described_recipe)
  end
  let(:supermarket) { chef_run.node['supermarket'] }
  let(:supermarket_oauth2) { supermarket_oc_id_config }
  let(:callback) do
    "#{supermarket['chef_server_url']}/auth/chef_oauth2/callback"
  end

  before { stub_combined_config }

  it 'sets the chef server url node attribute' do
    expect(supermarket['chef_server_url'])
      .to eq("https://#{chef_run.node['fqdn']}")
  end

  it 'sets the database node attributes' do
    expect(supermarket['postgresql']['username']).to eq('opscode-pgsql')
    expect(supermarket['database']['host']).to eq('localhost')
    expect(supermarket['database']['port']).to eq(5432)
  end

  it 'sets the nginx node attributes' do
    expect(supermarket['nginx']['user']).to eq('opscode')
    expect(supermarket['nginx']['group']).to eq('opscode')
    expect(supermarket['nginx']['directory'])
      .to eq('/var/opt/opscode/nginx/etc')
    expect(supermarket['nginx']['log_directory'])
      .to eq('/var/log/opscode/nginx')
  end

  it 'disables unused services' do
    %w(redis nginx postgresql).each do |service|
      expect(supermarket[service]['enable']).to eq(false)
    end
  end

  it 'sets the oauth2 node attributes' do
    expect(supermarket['chef_oauth2_app_id'])
      .to eq(supermarket_oauth2['uid'])
    expect(supermarket['chef_oauth2_secret'])
      .to eq(supermarket_oauth2['secret'])
    expect(supermarket['chef_oauth2_url']).to eq(callback)
  end

  it 'configures chef server oc-id' do
    expect(chef_run).to create_oc_id_application('supermarket')
  end
end
