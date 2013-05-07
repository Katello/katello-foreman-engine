require 'test_helper'

module KatelloForemanEngine
  module Actions
    class OrgDestroyTest < ActiveSupport::TestCase

      test "runs only when the org is present in Foreman" do
        foreman_org = { 'organization' => { 'id' => '123' } }
        Bindings.expects(:organization_find).with('KT-[test]').returns(foreman_org)
        plan = prepare_plan(OrgDestroy, {'label' => 'test'}, nil)
        step = plan.run_steps.first
        assert_equal OrgDestroy, step.action_class
        assert_equal step.input['foreman_id'], '123'

        Bindings.expects(:organization_find).returns(nil)
        plan = prepare_plan(OrgDestroy, {'label' => 'test'}, nil)
        assert_equal [], plan.run_steps
      end

      test 'calls bindings to destroy organization' do
        Bindings.expects(:organization_destroy).with('123')
        OrgDestroy.new('foreman_id' => '123').run
      end

    end
  end
end
