describe 'omnibus-supermarket::redis' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.automatic['memory']['total'] = '16000MB'
    end.converge(described_recipe)
  end

  before :each do
    stub_command("grep 'SUP:123456:respawn:/opt/supermarket/embedded/bin/runsvdir-start' /etc/inittab")
  end

  it 'creates /var/log/supermarket/redis' do
    expect(chef_run).to create_directory('/var/log/supermarket/redis').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700',
    )
  end

  it 'creates /var/opt/supermarket/redis/etc' do
    expect(chef_run).to create_directory('/var/opt/supermarket/redis/etc').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700',
    )
  end

  it 'creates /var/opt/supermarket/redis/etc/redis.conf' do
    expect(chef_run).to create_template(
      '/var/opt/supermarket/redis/etc/redis.conf'
    ).with(
      owner: 'supermarket',
      group: 'supermarket',
      mode: '0600',
    )
  end

  it 'creates /var/opt/supermarket/lib/redis' do
    expect(chef_run).to create_directory('/var/opt/supermarket/lib/redis').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700',
    )
  end

  it 'creates /var/opt/supermarket/redis/run' do
    expect(chef_run).to create_directory('/var/opt/supermarket/redis/run').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700',
    )
  end

  it 'applies sysctl params' do
    expect(chef_run).to apply_sysctl_param('vm.overcommit_memory').with(
      value: 1
    )
  end
end
