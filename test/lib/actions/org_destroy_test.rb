require 'test_helper'

module KatelloForemanEngine
  module Actions
    class OrgDestroyTest < ActiveSupport::TestCase

      test "runs only when the org is present in Foreman" do
        foreman_org = { 'organization' => { 'id' => '123' } }
        Bindings.expects(:organization_find).with('test').returns(foreman_org)
        step = run_steps(OrgDestroy, {'label' => 'test'}, nil).first
        assert_equal OrgDestroy, step.action_class
        assert_equal step.input['foreman_id'], '123'

        Bindings.expects(:organization_find).returns(nil)
        assert_equal [], run_steps(OrgDestroy, {'label' => 'test'}, nil)
      end

      test 'calls bindings to destroy organization' do
        Bindings.expects(:organization_destroy).with('123')
        OrgDestroy.new('foreman_id' => '123').run
      end

    end
  end
end
