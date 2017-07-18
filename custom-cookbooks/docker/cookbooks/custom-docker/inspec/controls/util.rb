title 'Utility instances'

control 'docker service' do
  describe docker do
    its('graph_directory') { should eq '/data/docker/graph' }

    its('storage_driver') { should eq 'overlay' }
  end

  describe processes('dockerd') do
    its('list.length') { should eq 1 }
  end
end
