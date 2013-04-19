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
          },
        }
      end

      def base
        base = ForemanApi::Base.new(client_config)
        base.client.options[:headers][:foreman_user] = 'admin'
        base
      end

      def organization_create(name)
        base.http_call('post', '/api/organizations',
                       :organization => {:name => name,
                         :ignore_types => %w[User SmartProxy Subnet ComputeResource Medium ConfigTemplate Domain Environment] })
      end

      def environment_find(org_label, env_label, cv_label = nil)
        base.http_call('get', '/foreman_katello_engine/api/environments/show',
                       {:org => org_label, :env => env_label, :cv => cv_label})
      rescue RestClient::ResourceNotFound => e
        return nil
      end

      def environment_create(cv_id, org_label, env_label, cv_label = nil)
        base.http_call('post', '/foreman_katello_engine/api/environments',
                       {:org => org_label, :env => env_label, :cv => cv_label, :cv_id => cv_id})
      end

      def environment
        ForemanApi::Resources::Environment.new(client_config)
      end

    end
  end

end


