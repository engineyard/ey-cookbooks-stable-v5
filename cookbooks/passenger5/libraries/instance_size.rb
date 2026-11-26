class Chef
  class Node
    def ec2_instance_size
      @ec2_instance_size = "m1.small" if self[:instance_role] == "eylocal"
      # Fetch via IMDSv2 token handshake with IMDSv1 fallback (see ey-lib
      # libraries/imds.rb). Use the fully-qualified ::EY::IMDS: a bare `EY::IMDS`
      # inside `class Chef` resolves to the non-existent `Chef::EY::IMDS`.
      @ec2_instance_size ||= ::EY::IMDS.get("latest/meta-data/instance-type")
    end
  end
end
