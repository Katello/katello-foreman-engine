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

    class ChangesetPromote < Dynflow::Action

      def self.subscribe
        Katello::Actions::ChangesetPromote
      end

      def plan(changeset)
        # demotion is handed by DistributionUnpublish action
        return unless changeset.is_a? PromotionChangeset
        changeset.affected_repos.each do |repo|
          repo = repo.get_clone(changeset.environment)
          plan_action(RepositoryChange, repo)
        end
      end

    end
  end
end
