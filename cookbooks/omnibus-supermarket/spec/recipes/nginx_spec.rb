describe 'omnibus-supermarket::nginx' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.automatic['memory']['total'] = '16000MB'
    end.converge(described_recipe)
  end

  context 'standalone mode' do
    it 'creates /var/log/supermarket/nginx' do
      expect(chef_run).to create_directory('/var/log/supermarket/nginx').with(
        user: 'supermarket',
        group: 'supermarket',
        mode: '0700',
      )
    end

    it 'creates /var/opt/supermarket/nginx/etc' do
      expect(chef_run).to create_directory('/var/opt/supermarket/nginx/etc').with(
        user: 'supermarket',
        group: 'supermarket',
        mode: '0700',
      )
    end

    it 'creates /var/opt/supermarket/nginx/etc/conf.d' do
      expect(chef_run).to create_directory('/var/opt/supermarket/nginx/etc/conf.d').with(
        user: 'supermarket',
        group: 'supermarket',
        mode: '0700',
      )
    end

    it 'creates /var/opt/supermarket/nginx/etc/sites_enabled' do
      expect(chef_run).to create_directory('/var/opt/supermarket/nginx/etc/sites-enabled').with(
        user: 'supermarket',
        group: 'supermarket',
        mode: '0700',
      )
    end

    it 'creates /var/opt/supermarket/nginx/etc/nginx.conf' do
      expect(chef_run).to create_template('/var/opt/supermarket/nginx/etc/nginx.conf').with(
        source: 'nginx.conf.erb',
        owner: 'supermarket',
        group: 'supermarket',
        mode: '0600',
      )
    end

    it 'symlinks the mime types' do
      expect(chef_run.link('/var/opt/supermarket/nginx/etc/mime.types')).to link_to(
        '/opt/supermarket/embedded/conf/mime.types'
      )
    end

    it 'notifies nginx to reload when it renders the config' do
      expect(chef_run.template('/var/opt/supermarket/nginx/etc/nginx.conf'))
        .to notify('runit_service[nginx]').to(:restart)
    end
  end

  context 'combined mode' do
    before { stub_combined_config }

    it 'symlinks the mime types' do
      expect(chef_run.link('/var/opt/opscode/nginx/etc/mime.types')).to link_to(
        '/opt/supermarket/embedded/conf/mime.types'
      )
    end
  end
end
