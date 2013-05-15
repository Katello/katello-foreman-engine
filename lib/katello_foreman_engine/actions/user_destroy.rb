module KatelloForemanEngine
  module Actions
    class UserDestroy < Dynflow::Action

      def self.subscribe
        Headpin::Actions::UserDestroy
      end

      def plan(user)
        if foreman_user = Bindings.user_find(input['username'])
          plan_self 'foreman_user_id' => foreman_user['id']
        end
      end

      input_format do
        param :foreman_user_id, String
      end

      def run
        Bindings.user_destroy(input['foreman_user_id'])
      end
    end
  end
end
