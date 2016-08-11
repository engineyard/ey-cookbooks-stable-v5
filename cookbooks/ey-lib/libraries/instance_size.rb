class Chef
  class Node
    def ec2_instance_size
      @ec2_instance_size ||= open("http://169.254.169.254/latest/meta-data/instance-type").read
    end
  end
end
