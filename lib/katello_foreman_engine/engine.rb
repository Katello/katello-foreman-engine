module KatelloForemanEngine
  #Inherit from the Rails module of the parent app (Foreman), not the plugin.
  #Thus, inhereits from ::Rails::Engine and not from Rails::Engine
  class Engine < ::Rails::Engine

    config.after_initialize do
      require 'katello_foreman_engine/settings'
      Settings.initialize_settings
      require 'katello_foreman_engine/bindings'
      Dir[File.expand_path('../actions/*.rb', __FILE__)].each { |f| require f }
    end

  end
end
