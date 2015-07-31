describe 'omnibus-supermarket::sendmail' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.automatic['memory']['total'] = '16000MB'
    end.converge(described_recipe)
  end

  it 'installs sendmail' do
    expect(chef_run).to install_package('sendmail')
  end

end
