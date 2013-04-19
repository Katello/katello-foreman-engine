require 'foreman_api'

module KatelloForemanEngine
  module Bindings

    class << self

      def client_config
        {
          :base_url => Settings['foreman_url'],
          :enable_validations => false,
          :oauth => {
            :consumer_key => Settings['oauth_consumer_key'],
            :consumer_secret => Settings['oauth_consumer_secret']
          }
        }
      end

      def organization
        ForemanApi::Resources::Organization.new(client_config)
      end

      def environment
        ForemanApi::Resources::Environment.new(client_config)
      end

    end
  end

end


