module KatelloForemanEngine
  module Actions
    class OrgDestroy < Dynflow::Action

      input_format do
        param :foreman_id, String
      end

      def self.subscribe
        Headpin::Actions::OrgDestroy
      end

      def plan(org)
        if foreman_org = Bindings.organization_find(input['label'])
          plan_self('foreman_id' => foreman_org['organization']['id'])
        end
      end

      def run
        Bindings.organization_destroy(input['foreman_id'])
      end
    end
  end
end
