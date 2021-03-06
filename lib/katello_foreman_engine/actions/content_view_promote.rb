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
    class ContentViewPromote < Dynflow::Action

      def self.subscribe
        Katello::Actions::ContentViewPromote
      end

      def plan(content_view, from_env, to_env)
        unless Bindings.environment_find(input['organization_label'], input['to_env_label'], input['label'])
          plan_self input
        end
        content_view.repos(to_env).each do |repo|
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
