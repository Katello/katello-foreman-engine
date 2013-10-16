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
    class ContentViewPublish < Dynflow::Action

      def self.subscribe
        [Katello::Actions::ContentViewPublish,
         Katello::Actions::ContentViewRefresh]
      end

      def plan(content_view)
        unless Bindings.environment_find(content_view.organization.label, 'Library', content_view.label) 
          plan_self('id' => content_view.id,
                    'label' => content_view.label,
                    'organization_label' => content_view.organization.label)
        end
        content_view.repos(content_view.organization.library).each do |repo|
          plan_action(RepositoryChange, repo)
        end
      end

      input_format do
        param :id, Integer
        param :label, String
        param :organization_label, String
      end

      def run
        Bindings.environment_create(input['id'], input['organization_label'], 'Library', input['label'])
      end
    end
  end
end
