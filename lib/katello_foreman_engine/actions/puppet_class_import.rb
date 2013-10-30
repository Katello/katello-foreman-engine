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
    class PuppetClassImport < Dynflow::Action
      input_format do
        param :organization_label, String
        param :environment_label, String
        param :content_view_label, String
        param :smart_proxy_id, String
      end

      def plan(organization_label, environment_label, content_view_label)
        proxies, response = Bindings.smart_proxy.index
        smart_proxy       = proxies.find do |sp|
          sp.fetch('smart_proxy').fetch('name') == Katello.config.host
        end

        if smart_proxy
          smart_proxy_id = smart_proxy.fetch('smart_proxy').fetch('id')
          plan_self 'organization_label' => organization_label,
                    'environment_label'  => environment_label,
                    'content_view_label' => content_view_label,
                    'smart_proxy_id'     => smart_proxy_id
        end
      end

      def run
        env, response   = Bindings.environment_find(input['organization_label'],
                                                    input['environment_label'],
                                                    input['content_view_label'])
        env_id          = env.fetch('environment').fetch('id')
        dryrun, _       = Bindings.import_puppet_class input['smart_proxy_id'], env_id, true
        output['dryrun'] = dryrun
        # run import only when it won't delete the environment
        if dryrun.key?('results') && !dryrun.fetch('results').fetch('actions').include?('obsolete')
          output['import_executed'] = true
          Bindings.import_puppet_class input['smart_proxy_id'], env_id
        else
          output['import_executed'] = false
        end
      end
    end
  end
end
