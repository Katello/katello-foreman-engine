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
