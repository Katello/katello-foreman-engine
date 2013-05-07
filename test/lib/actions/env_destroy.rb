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
        plan = prepare_plan(EnvDestroy,{}, env)
        step = plan.run_steps.first
        assert_equal EnvDestroy, step.action_class
        assert_equal step.input['foreman_id'], '123'

        env.library = true
        plan = prepare_plan(EnvDestroy, {}, env)
        assert_equal [], plan.run_steps

        env.library = false
        Bindings.expects(:environment_find).returns(nil)
        plan = prepare_plan(EnvDestroy, {}, env)
        assert_equal [], plan.run_steps
      end

      test 'calls bindings to destroy environment' do
        Bindings.expects(:environment_destroy).with('123')
        EnvDestroy.new('foreman_id' => '123').run
      end

    end
  end
end
