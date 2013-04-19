module KatelloForemanEngine
  module Actions
    class EnvCreate < Dynflow::Action

      def self.subscribe
        Katello::Actions::EnvCreate
      end

      def plan(env)
        unless env.library?
          plan_self 'org_label' => env.organization.label, 'label' => env.label, 'cv_id' => env.default_content_view.id
        end
      end

      input_format do
        param :org_label, String
        param :label, String
        param :cv_id, String
      end

      def run
        Bindings.environment_create(input['cv_id'], input['org_label'], input['label'])
      end
    end
  end
end
