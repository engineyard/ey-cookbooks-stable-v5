class SwapThresholds

  # default warning is on the 50% of swap size reached
  def warning_total(warning_value="0.50")
    swap_total * warning_value.to_f
  end

  # default warning is on the 70% of swap size reached
  def critical_total(critical_value="0.70" )
    swap_total * critical_value.to_f
  end

  # returns the swap size for the system
  def swap_total
    Mixlib::ShellOut.new("cat /proc/meminfo").run_command.stdout.scan(/^SwapTotal:\s+(\d+)\skB$/).flatten.first.to_i * 1024 
  end

end

