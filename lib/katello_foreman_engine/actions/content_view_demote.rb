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
    class ContentViewDemote < Dynflow::Action

      def self.subscribe
        Katello::Actions::ContentViewDemote
      end

      def plan(content_view, from_env)
        if foreman_env = Bindings.environment_find(content_view.organization.label,
                                                   from_env.label, content_view.label)
          plan_self 'foreman_env_id' => foreman_env['environment']['id']
        end
      end

      input_format do
        param :foreman_env_id, Integer
      end

      def run
        Bindings.environment_destroy(input['foreman_env_id'])
      end
    end
  end
end
