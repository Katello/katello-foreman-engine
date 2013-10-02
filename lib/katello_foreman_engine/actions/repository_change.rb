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

    class RepositoryChange < Dynflow::Action

      def self.subscribe
        [Katello::Actions::RepositorySync]
      end

      def plan(repo)
        if repo.distributions.empty?
          # no distributions, no instalation media
          plan_action(DistributionUnpublish, repo)
        elsif(repo.unprotected)
          repo_info = {
            'pulp_id' => repo.pulp_id,
            'uri' => repo.uri,
            'label'   => repo.label,
            'product_label'   => repo.product.label,
            'environment_label'   => repo.environment.label,
            'organization_label'   => repo.organization.label
          }

          if repo.content_view && !repo.content_view.default?
            repo_info['content_view_label'] = repo.content_view.label
          end

          # Foreman's installation media don't distinguish between
          # different variants. Using just a first one.
          distribution = repo.distributions.first
          plan_action(DistributionPublish,
                      { 'repo' => repo_info,
                        'family' => distribution.family,
                        'variant' => distribution.variant,
                        'arch' => distribution.arch,
                        'version' => distribution.version })
        end
      end

    end
  end
end
