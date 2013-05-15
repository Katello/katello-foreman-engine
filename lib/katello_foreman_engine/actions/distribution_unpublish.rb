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
