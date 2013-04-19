module KatelloForemanEngine
  #Inherit from the Rails module of the parent app (Foreman), not the plugin.
  #Thus, inhereits from ::Rails::Engine and not from Rails::Engine
  class Engine < ::Rails::Engine

    config.after_initialize do
      require 'katello_foreman_engine/bindings'
      require 'katello_foreman_engine/settings'
      require 'katello_foreman_engine/actions/org_create'
    end

  end
end
