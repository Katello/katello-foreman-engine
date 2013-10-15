require 'test_helper'

module KatelloForemanEngine
  module Actions
    class EnvDestroyTest < ActiveSupport::TestCase

      test "runs only when the env is present in Foreman and it's not library" do
        org = Organization.new(:label => 'org')
        env = KTEnvironment.new(:label => 'dev')
        env.organization = org

        assert_equal [], run_steps(EnvironmentDestroy,{}, env)
      end
    end
  end
end
