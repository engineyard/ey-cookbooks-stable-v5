class VariableTargetDevice
  attr_reader :targets

  def initialize(type,targets)
    @type = type
    @targets = targets
    @success = false
    Chef::Log.info "#{targets} selected as candidates for #{type}"
  end

  def device
    return nil unless found?
    @targets[@found_index]
  end

  def found?
    @success ||= find_mounted_target
  end

  private

  def find_mounted_target
    @targets.each_with_index do |target,i|
      if File.exists?(target)
        @found_index = i
        return true
      else
        Chef::Log.info("EBS device #{target} for #{@type} not available yet...")
      end
    end
    false
  end
end
