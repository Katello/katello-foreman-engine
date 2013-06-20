module KatelloForemanEngine
  module Actions
    class DistributionPublish < Dynflow::Action

      input_format do
        param :family, String,  "Example: Red Hat Enterprise Linux"
        param :variant, String, "Example: Server"
        param :arch, String,    "Example: x86_64"
        param :version, String, "Example: 6.3"
        param :repo, Hash do
          param :pulp_id
          param :uri, String, "Example: https://example.com/pulp/repos/org/env/pr/os/"
          param :label
          param :product_label
          param :content_view_label
          param :environment_label
          param :organization_label
        end
      end

      def run
        medium_name = construct_medium_name
        medium_path = Helpers.installation_media_path(input['repo']['uri'])
        org_label = input['repo']['organization_label']
        return if Bindings.medium_find(medium_path)

        arch = find_or_create_arch
        os = find_or_create_operating_system
        assign_arch_to_os(os, arch)
        medium = Bindings.medium_create(medium_name, medium_path, org_label)
        assign_medium_to_os(os, medium)
      end

      private

      def find_or_create_arch
        arch = Bindings.architecture_find(input['arch']) ||
          Bindings.architecture_create(input['arch'])
        return arch
      end

      def find_or_create_operating_system
        os_name = construct_operating_system_name
        major, minor = input['version'].split('.')

        os = Bindings.operating_system_find(os_name, major, minor)
        unless os
          os = Bindings.operating_system_create(os_name, major, minor)
        end

        return os
      end

      def assign_arch_to_os(os, arch)
        if os['architectures']
          arch_ids = os['architectures'].map { |a| a['architecture']['id'] }
        else
          arch_ids = []
        end
        unless arch_ids.include?(arch['id'])
          arch_ids << arch['id']
          data = {'architecture_ids' => arch_ids}
          Bindings.operating_system_update(os['id'], data)
        end
      end

      def assign_medium_to_os(os, medium)
        if os['media']
          medium_ids = os['media'].map { |a| a['medium']['id'] }
        else
          medium_ids = []
        end
        unless medium_ids.include?(medium['id'])
          medium_ids << medium['id']
          data = {'medium_ids' => medium_ids}
          Bindings.operating_system_update(os['id'], data)
        end
      end


      def construct_medium_name
        parts = []
        parts << [
                  input['repo']['organization_label'],
                  input['repo']['environment_label'],
                  input['repo']['content_view_label']
                 ].compact.join('/')
        parts << input['family']
        parts << input['variant']
        parts << input['version']
        parts << input['arch']
        name = parts.reject(&:blank?).join(' ')
        # we need to make the name a bit shorter to get under 50
        # charatcers for medium name
        name.sub!('Red Hat Enterprise Linux','RHEL')
        return name
      end

      def construct_operating_system_name
        [input['family'], input['variant']].join(' ').gsub(' ', '_')
      end

    end
  end
end
