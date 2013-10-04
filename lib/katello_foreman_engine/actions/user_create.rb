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
