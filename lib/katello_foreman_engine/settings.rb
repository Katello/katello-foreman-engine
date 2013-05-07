module KatelloForemanEngine
  class Settings

    def self.initialize_settings
      @settings = {
        'foreman_url' => Katello.config.foreman.url.sub(/\/+\Z/,''),
        'oauth_consumer_key' => Katello.config.foreman.oauth_key,
        'oauth_consumer_secret' => Katello.config.foreman.oauth_secret
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
