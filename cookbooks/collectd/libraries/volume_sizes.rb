class DiskThresholds

  # If the volume is <= ~10GB then warn on 30%
  # otherwise warn on 20%
  def warning_for(mountpoint)
    if volume_size(mountpoint,:gigabytes) <= 10
      volume_size(mountpoint) * 0.3
    else
      volume_size(mountpoint) * 0.2
    end
  end

  # Fail on 10% of free space
  def failure_for(mountpoint)
    volume_size(mountpoint) * 0.1
  end

  private

  # returns the volume size in the units specified
  # defaults to :bytes
  def volume_size(mountpoint,units=:bytes)

    raise(VolumeNotFoundException, "Cannot find #{mountpoint}") unless File.exists?(mountpoint)

    df_block = case units
               when :bytes
                 '1'
               when :megabytes
                 '1M'
               when :gigabytes
                 '1G'
               when :terabytes
                 '1T'
               else
                 '1'
               end
    Mixlib::ShellOut.new("df -B#{df_block} #{mountpoint} | awk '/dev/ {print $2}'").run_command.stdout.strip.to_i
  end

end

class VolumeNotFoundException < StandardError; end
