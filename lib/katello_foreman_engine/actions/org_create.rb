module KatelloForemanEngine
  module Actions
    class OrgCreate < Dynflow::Action

      def self.subscribe
        Headpin::Actions::OrgCreate
      end

      def run
        Bindings.organization_create("KT-[#{input['label']}]")
      end
    end
  end
end
