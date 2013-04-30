module KatelloForemanEngine
  module Actions
    class ContentViewDemote < Dynflow::Action

      def self.subscribe
        Katello::Actions::ContentViewDemote
      end

      def plan(content_view, from_env)
        if foreman_env = Bindings.environment_find(content_view.organization.label,
                                                   from_env.label, content_view.label)
          plan_self 'foreman_env_id' => foreman_env['environment']['id']
        end
      end

      input_format do
        param :foreman_env_id, Integer
      end

      def run
        Bindings.environment_destroy(input['foreman_env_id'])
      end
    end
  end
end
