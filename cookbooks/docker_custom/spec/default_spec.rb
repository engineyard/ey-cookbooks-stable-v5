require 'chefspec'

describe 'docker_custom::default' do
  let :chef_run do
    runner.converge described_recipe
  end

  let :runner do
    ChefSpec::SoloRunner.new platform: 'gentoo', version: '2.1'
  end

  context 'in utility instances' do
    let :runner do
      ChefSpec::SoloRunner.new(platform: 'gentoo', version: '2.1') do |node|
        node.default['dna'].tap do |dna|
          dna['instance_role'] = 'util'
          dna['name'] = 'docker'
          
        end
      end
    end 
    it 'installs docker' do
      expect(chef_run).to include_recipe 'docker_custom::install'
    end
  end

  context 'in other instances' do
    it 'does nothing' do
      expect(chef_run).to_not include_recipe 'docker_custom::install'
    end
  end
end
