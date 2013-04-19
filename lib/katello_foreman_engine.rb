module KatelloForemanEngine
  if defined?(Rails) && Rails::VERSION::MAJOR == 3
    require 'katello_foreman_engine/engine'
  end
end
