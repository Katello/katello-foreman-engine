require 'test_helper'

module KatelloForemanEngine
  module Actions
    class EnvCreateTest < ActiveSupport::TestCase

      test "doesn't run for library" do
        org = Organization.new(:label => 'org')
        env = KTEnvironment.new(:label => 'dev')
        env.organization = org

        env.library = false
        plan = prepare_plan(EnvCreate, {}, env)
        step = plan.run_steps.first
        assert_equal EnvCreate, step.action_class
        assert_equal step.input['org_label'], 'org'
        assert_equal step.input['label'], 'dev'
        assert_equal step.input['cv_id'], 'env'

        env.library = true
        plan = prepare_plan(EnvCreate, {}, env)
        assert_equal [], plan.run_steps
      end

      test 'calls bindings to create environment' do
        Bindings.expects(:environment_create).with('env', 'org', 'dev')
        EnvCreate.new('org_label' => 'org', 'label' => 'dev', 'cv_id' => 'env').run
      end

    end
  end
end
