class Chef
  class Node
    def ec2_instance_size
      # Fetch via IMDSv2 token handshake with IMDSv1 fallback (see ey-lib
      # libraries/imds.rb). Use the fully-qualified ::EY::IMDS: this method is
      # lexically nested in `class Chef`, and ey-lib already defines a
      # `Chef::EY` namespace (ey-engineyard.rb etc.), so a bare `EY::IMDS` would
      # resolve to the non-existent `Chef::EY::IMDS` and raise NameError.
      @ec2_instance_size ||= ::EY::IMDS.get("latest/meta-data/instance-type")
    end
  end
end
