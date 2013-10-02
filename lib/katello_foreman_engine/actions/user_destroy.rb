#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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
