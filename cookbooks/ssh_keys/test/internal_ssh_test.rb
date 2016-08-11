module SshKeysCookbook
  class InternalSshTest < EY::Sommelier::TestCase
    scenario :gamma

    def test_inter_cluster_ssh
      instances.each do |me|
        instances.reject {|other| me == other }.each do |other|
          me.ssh!("su #{template.ssh_username} -lc 'ssh -i ~/.ssh/internal -o StrictHostKeyChecking=no -o CheckHostIP=no #{other.public_hostname} /bin/true'")
        end
      end
    end
  end
end
