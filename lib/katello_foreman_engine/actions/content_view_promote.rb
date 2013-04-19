module KatelloForemanEngine
  module Actions
    class ContentViewPromote < Dynflow::Action

      def self.subscribe
        Katello::Actions::ContentViewPromote
      end

      def plan(*args)
        unless Bindings.environment_find(input['org_label'], input['to_env_label'], input['label'])
          plan_self input
        end
      end

      input_format do
        param :id, Integer
        param :label, String
        param :org_label, String
        param :from_env_label, String
        param :to_env_label, String
      end

      def run
        Bindings.environment_create(input['id'], input['org_label'], input['to_env_label'], input['label'])
      end
    end
  end
end
