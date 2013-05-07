module KatelloForemanEngine
  module Actions
    class EnvironmentCreate < Dynflow::Action

      def self.subscribe
        Katello::Actions::EnvironmentCreate
      end

      def plan(env)
        unless env.library?
          plan_self 'org_label' => env.organization.label, 'label' => env.label, 'content_view_id' => 'env'
        end
      end

      input_format do
        param :org_label, String
        param :label, String
        param :content_view_id, String
      end

      def run
        Bindings.environment_create(input['content_view_id'], input['org_label'], input['label'])
      end
    end
  end
end
