module KatelloForemanEngine
  module Helpers
    class << self

      # takes repo uri from Katello and makes installation media url
      # suitable for provisioning from it
      def installation_media_path(repo_uri)
        path = repo_uri.sub(/\Ahttps/, 'http')
        path << "/" unless path.end_with?('/')
        return path
      end
    end

  end
end
