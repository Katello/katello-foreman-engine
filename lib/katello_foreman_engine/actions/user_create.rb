module KatelloForemanEngine
  module Actions
    class UserCreate < Dynflow::Action

      def self.subscribe
        Headpin::Actions::UserCreate
      end

      def plan(user)
        if !user.hidden? && !Bindings.user_find(input['username'])
          plan_self input
        end
      end

      def run
        Bindings.user_create(input['username'], input['email'], input['admin'])
      end
    end
  end
end
