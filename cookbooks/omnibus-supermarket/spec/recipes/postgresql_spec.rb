describe 'omnibus-supermarket::postgresql' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.automatic['memory']['total'] = '16000MB'
    end.converge(described_recipe)
  end

  before :each do
    stub_command("grep 'SUP:123456:respawn:/opt/supermarket/embedded/bin/runsvdir-start' /etc/inittab")
  end

  context 'standalone mode' do
    it 'creates /var/log/supermarket/postgresql' do
      expect(chef_run).to create_directory('/var/log/supermarket/postgresql').with(
        user: 'supermarket',
        group: 'supermarket',
        mode: '0700',
      )
    end

    it 'sets shmmax sysctl param' do
      expect(chef_run).to apply_sysctl_param('kernel.shmmax').with(
        value: 17179869184
      )
    end

    it 'sets shmall sysctl param' do
      expect(chef_run).to apply_sysctl_param('kernel.shmall').with(
        value: 4194304
      )
    end
  end

  context 'combined mode' do
    before { stub_combined_config }

    it 'starts chef server postgresql' do
      expect(chef_run).to run_execute('chef-server-ctl start postgresql')
    end
  end
end
