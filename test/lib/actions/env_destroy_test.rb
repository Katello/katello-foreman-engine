require 'test_helper'

module KatelloForemanEngine
  module Actions
    class EnvDestroyTest < ActiveSupport::TestCase

      test "runs only when the env is present in Foreman and it's not library" do
        org = Organization.new(:label => 'org')
        env = KTEnvironment.new(:label => 'dev')
        env.organization = org

        foreman_env = { 'environment' => { 'id' => '123' } }
        Bindings.expects(:environment_find).with('org', 'dev').returns(foreman_env)

        env.library = false
        step = run_steps(EnvironmentDestroy,{}, env).first
        assert_equal EnvironmentDestroy, step.action_class
        assert_equal step.input['foreman_id'], '123'

        env.library = true
        assert_equal [], run_steps(EnvironmentDestroy,{}, env)

        env.library = false
        Bindings.expects(:environment_find).returns(nil)
        assert_equal [], run_steps(EnvironmentDestroy,{}, env)
      end

      test 'calls bindings to destroy environment' do
        Bindings.expects(:environment_destroy).with('123')
        EnvironmentDestroy.new('foreman_id' => '123').run
      end

    end
  end
end
