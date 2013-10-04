module KatelloForemanEngine
  class Settings

    def self.initialize_settings
      @settings = {
        'foreman_url' => Katello.config.foreman.url.sub(/\/+\Z/,''),
        'oauth_consumer_key' => Katello.config.foreman.oauth_key,
        'oauth_consumer_secret' => Katello.config.foreman.oauth_secret,
        # TODO: make the following options configurable:
        'foreman_os_family' => 'Redhat',
        'foreman_os_rhel_provisioning_template' => 'Katello Kickstart Default for RHEL',
        'foreman_os_provisioning_template' => 'Katello Kickstart Default',
        'foreman_os_pxe_template' => 'Kickstart default PXElinux',
        'foreman_os_ptable' => 'RedHat default',
      }
    end

    def self.[](key)
      @settings[key.to_s]
    end

    def self.[]=(key, value)
      @settings[key.to_s] = value
    end

  end
end
