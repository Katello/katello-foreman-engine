require 'test_helper'

module KatelloForemanEngine
  module Actions
    class EnvCreateTest < ActiveSupport::TestCase

      test "doesn't run for library" do
        org = Organization.new(:label => 'org')
        env = KTEnvironment.new(:label => 'dev')
        env.organization = org

        env.library = false
        step = run_steps(EnvironmentCreate, {}, env).first
        assert_equal EnvironmentCreate, step.action_class
        assert_equal 'org', step.input['org_label']
        assert_equal 'dev', step.input['label']
        assert_equal 'env', step.input['content_view_id']

        env.library = true
        assert_equal [], run_steps(EnvironmentCreate, {}, env)
      end

      test 'calls bindings to create environment' do
        Bindings.expects(:environment_create).with('env', 'org', 'dev')
        EnvironmentCreate.new('org_label' => 'org', 'label' => 'dev', 'content_view_id' => 'env').run
      end

    end
  end
end
