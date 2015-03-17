describe 'omnibus-supermarket::database' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.automatic['memory']['total'] = '16000MB'
    end.converge(described_recipe)
  end

  before do
    # Stub out the guards
    stub_command("echo 'dx' | psql supermarket | grep pgpsql").and_return(false)
    stub_command("echo 'dx' | psql supermarket | grep pg_trgm").and_return(false)
  end

  it 'creates /var/opt/supermarket/etc/database.yml' do
    expect(chef_run).to create_file(
      '/var/opt/supermarket/etc/database.yml'
    ).with(
      owner: 'supermarket',
      group: 'supermarket',
      mode: '0600'
    )
  end

  it 'symlinks database.yml' do
    expect(chef_run.link('/opt/supermarket/embedded/service/supermarket/config/database.yml'))
      .to link_to('/var/opt/supermarket/etc/database.yml')
  end
end
