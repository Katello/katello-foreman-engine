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
    class DistributionUnpublish < Dynflow::Action

      def self.subscribe
        Katello::Actions::RepositoryDestroy
      end

      input_format do
        param :medium_id, String
      end

      def plan(repo)
        path = Helpers.installation_media_path(repo.uri)
        if medium = Bindings.medium_find(path)
          plan_self('medium_id' => medium['id'])
        end
      end

      def run
        Bindings.medium_destroy(input['medium_id'])
      end

    end
  end
end
