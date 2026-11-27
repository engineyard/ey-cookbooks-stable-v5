class EC2CreditThresholds

  def initialize(apps_data)
    all_env_vars = merged_app_env_vars(apps_data)
    set_ec2_credit_thresholds(all_env_vars)
  end

  attr_reader :cpu_credit_ok, :cpu_credit_warn, :cpu_credit_alert,
    :vol_burst_ok, :vol_burst_warn, :vol_burst_alert

  private

  def merged_app_env_vars(apps_data)
    apps_data
      .map do |app_data|
        metadata = app_data['components'].find {|component| component['key'] == 'app_metadata'}
        return {} unless metadata && metadata['environment_variables']
        Hash[
          metadata['environment_variables'].collect do |var_hash|
            [ var_hash['name'], ::Base64.strict_decode64(var_hash['value']) ]
          end
        ]
      end
      .reduce({}, :merge)
  end

  def set_ec2_credit_thresholds(all_env_vars)
    @cpu_credit_ok = all_env_vars.fetch('EY_EC2_CPU_CREDITS_THRESHOLD_OK', 40)
    @cpu_credit_warn = all_env_vars.fetch('EY_EC2_CPU_CREDITS_THRESHOLD_WARN', 30)
    @cpu_credit_alert = all_env_vars.fetch('EY_EC2_CPU_CREDITS_THRESHOLD_ALERT', 15)
    @vol_burst_ok = all_env_vars.fetch('EY_IOPS_BURST_BALANCE_THRESHOLD_OK', 40)
    @vol_burst_warn = all_env_vars.fetch('EY_IOPS_BURST_BALANCE_THRESHOLD_WARN', 30)
    @vol_burst_alert = all_env_vars.fetch('EY_IOPS_BURST_BALANCE_THRESHOLD_ALERT', 15)
  end

end
