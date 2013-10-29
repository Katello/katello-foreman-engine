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

      def architecture
        resource(ForemanApi::Resources::Architecture)
      end

      def ptable
        resource(ForemanApi::Resources::Ptable)
      end

      def operating_system
        resource(ForemanApi::Resources::OperatingSystem)
      end

      def config_template
        resource(ForemanApi::Resources::ConfigTemplate)
      end

      def medium
        resource(ForemanApi::Resources::Medium)
      end

      def smart_proxy
        resource(ForemanApi::Resources::SmartProxy)
      end

      def user(username = nil)
        user_resource = resource(ForemanApi::Resources::User)
        if username && User.current.username == username
          # this means the first user is created: use the predefined
          # Foreman admin user for this cases.
          user_resource.client.options[:headers][:foreman_user] = 'admin'
        end
        return user_resource
      end

      def organization_find(kt_label)
        name = "KT-[#{kt_label}]"
        orgs, _ = base.http_call('get', '/api/organizations', 'search' => "name = #{name}")
        return orgs.first
      end

      def organization_create(name)
        base.http_call('post', '/api/organizations',
                       :organization => {:name => name,
                         :ignore_types => %w[User SmartProxy Subnet ComputeResource ConfigTemplate Domain] })
      end

      def organization_destroy(id)
        base.http_call('delete', "/api/organizations/#{id}")
      end


      def environment_find(org_label, env_label, content_view_label = nil)
        env, _ = base.http_call('get', '/foreman_katello_engine/api/environments/show',
                                {:org => org_label, :env => env_label, :content_view => content_view_label})
        return env
      rescue RestClient::ResourceNotFound => e
        return nil
      end

      def environment_create(content_view_id, org_label, env_label, content_view_label = nil)
        params = {:org => org_label, :env => env_label, :content_view => content_view_label, :content_view_id => content_view_id}
        if foreman_org = organization_find(org_label)
          params[:org_id] = foreman_org['organization']['id']
        end
        base.http_call('post', '/foreman_katello_engine/api/environments', params)
      end

      def environment_destroy(id)
        environment.destroy('id' => id)
      end

      def user_find(username)
        find_resource(user(username), "login = #{username}")
      end

      def user_create(username, email, admin)
        user(username).create({ 'user' => {
                                  'login' => username,
                                  'mail' => email,
                                  'password' => Password.generate_random_string(25),
                                  'admin' => admin,
                                  'auth_source_id' => 1}})
      end

      def user_destroy(id)
        user.destroy('id' => id)
      end

      def architecture_find(name)
        find_resource(architecture, "name = #{name}")
      end

      def architecture_create(name)
        without_root_key { architecture.create('architecture' => {'name' => name}) }
      end

      def operating_system_find(name, major, minor)
        find_resource(operating_system, %{name = "#{name}" AND major = "#{major}" AND minor = "#{minor}"})
      end

      def operating_system_create(name, major, minor)
        data = {
          'name' => name,
          'major' => major.to_s,
          'minor' => minor.to_s,
          'family' => Settings['foreman_os_family']
        }
        provisioning_template_name = if name == 'RedHat'
                                       Settings['foreman_os_rhel_provisioning_template']
                                     else
                                       Settings['foreman_os_provisioning_template']
                                     end
        templates_to_add = [template_find(provisioning_template_name),
                            template_find(Settings['foreman_os_pxe_template'])].compact
        data['os_default_templates_attributes'] = templates_to_add.map do |template|
          {
            "config_template_id" => template["id"],
            "template_kind_id" => template["template_kind"]["id"],
          }
        end

        if ptable = ptable_find(Settings['foreman_os_ptable'])
          data['ptable_ids'] = [ptable['id']]
        end

        os = without_root_key { operating_system.create('operatingsystem' => data) }

        oss, _ = operating_system.index
        os_ids = oss.map { |o| o['operatingsystem']['id'] }
        templates_to_add.each do |template|
          # Because of http://projects.theforeman.org/issues/2500 we
          # have not way to add only the created os to the template.
          # As a workaround, we add all os to the template for now.
          config_template.update("id" => template['id'],
                                 'config_template' => {
                                   "operatingsystem_ids" => os_ids
                                 })
        end
        return os
      end

      def operating_system_update(id, data)
        without_root_key do
          operating_system.update('id' => id, 'operatingsystem' => data)
        end
      end

      def template_find(name)
        find_resource(config_template, %{name = "#{name}"})
      end

      def medium_find(path)
        find_resource(medium, %{path = "#{path}"})
      end

      def medium_create(name, path, org_label)
        params = {
          'name' => name,
          'path' => path,
          'os_family' => Settings['foreman_os_family']
        }
        if foreman_org = organization_find(org_label)
          params['organization_ids'] = [foreman_org['organization']['id']]
        end
        without_root_key do
          self.medium.create('medium' => params)
        end
      end

      def medium_destroy(id)
        self.medium.destroy('id' => id)
      end

      def ptable_find(name)
        find_resource(ptable, %{name = "#{name}"})
      end

      def import_puppet_class(smart_proxy_id, environment_id)
        environment.import_puppetclasses 'environment_id' => environment_id,
                                         'id'             => smart_proxy_id
      end

      private

      # configure resource client to be used to call Foreman.
      # We need to do this for every resoruce right now.
      # We might improve this on foreman_api side later.
      def resource(resource_class)
        client = resource_class.new(client_config)
        client.client.options[:headers][:foreman_user] = User.current.username
        return client
      end

      # From Foreman, the resource comes in form:
      #
      #   { 'resource' => { 'attr1' => 'val1', 'attr2' => 'val2' } }
      #
      # this method returns only the body, i.e.:
      #
      #   { 'attr1' => 'val1', 'attr2' => 'val2' }
      #
      # If block given, it expects the call to foreman_api from that
      #
      # We might improve this on foreman_api side later
      def without_root_key(resource_hash = nil, &block)
        if block
          resource_hash, _ = yield
        end
        if resource_hash
          resource_hash.values.first
        end
      end

      def find_resource(resource, search_query)
        results, _ =  resource.index('search' => search_query)
        return without_root_key(results.first)
      end

    end
  end

end


