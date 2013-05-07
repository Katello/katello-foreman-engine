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
        resource(ForemanApi::Base)
      end

      def environment
        resource(ForemanApi::Resources::Environment)
      end

      def user
        resource(ForemanApi::Resources::User)
      end

      def resource(resource_class)
        client = resource_class.new(client_config)
        client.client.options[:headers][:foreman_user] = 'admin'
        return client
      end

      def organization_find(name)
        orgs, _ = base.http_call('get', '/api/organizations', 'search' => "name = #{name}")
        return orgs.first
      end

      def organization_create(name)
        base.http_call('post', '/api/organizations',
                       :organization => {:name => name,
                         :ignore_types => %w[User SmartProxy Subnet ComputeResource Medium ConfigTemplate Domain Environment] })
      end

      def organization_destroy(id)
        base.http_call('delete', "/api/organizations/#{id}")
      end


      def environment_find(org_label, env_label, cv_label = nil)
        env, _ = base.http_call('get', '/foreman_katello_engine/api/environments/show',
                                {:org => org_label, :env => env_label, :cv => cv_label})
        return env
      rescue RestClient::ResourceNotFound => e
        return nil
      end

      def environment_create(cv_id, org_label, env_label, cv_label = nil)
        params = {:org => org_label, :env => env_label, :cv => cv_label, :cv_id => cv_id}
        if foreman_org = organization_find("KT-[#{org_label}]")
          params[:org_id] = foreman_org['organization']['id']
        end
        base.http_call('post', '/foreman_katello_engine/api/environments', params)
      end

      def environment_destroy(id)
        environment.destroy('id' => id)
      end

      def user_find(username)
        users, _ = user.index('search' => "login = #{username}")
        return users.first
      end

      def user_create(username, email)
        user.create({ 'user' => {
                        'login' => username,
                        'mail' => email,
                        'password' => Password.generate_random_string(25),
                        'auth_source_id' => 1}})
      end

      def user_destroy(id)
        user.destroy('id' => id)
      end

    end
  end

end


