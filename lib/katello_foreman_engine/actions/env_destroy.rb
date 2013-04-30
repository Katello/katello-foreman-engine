module KatelloForemanEngine
  module Actions
    class EnvDestroy < Dynflow::Action

      input_format do
        param :foreman_id, String
      end

      def self.subscribe
        Katello::Actions::EnvDestroy
      end

      def plan(env)
        if !env.library? && foreman_env = Bindings.environment_find(env.organization.label, env.label)
          env.content_views.each do |content_view|
            plan(ContentViewDestroy, content_view, env)
          end
          plan_self 'foreman_id' => foreman_env['environment']['id']
        end
      end

      def run
        Bindings.environment_destroy(input['foreman_id'])
      end
    end
  end
end
