module KatelloForemanEngine
  module Actions
    class ContentViewPromote < Dynflow::Action

      def self.subscribe
        Katello::Actions::ContentViewPromote
      end

      def plan(content_view, from_env, to_env)
        unless Bindings.environment_find(input['organization_label'], input['to_env_label'], input['label'])
          plan_self input
        end
        content_view.repos(to_env) do |repo|
          plan_action(RepositoryChange, repo)
        end
      end

      input_format do
        param :id, Integer
        param :label, String
        param :organization_label, String
        param :from_env_label, String
        param :to_env_label, String
      end

      def run
        Bindings.environment_create(input['id'], input['organization_label'], input['to_env_label'], input['label'])
      end
    end
  end
end
