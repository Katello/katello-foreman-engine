require 'test_helper'

module KatelloForemanEngine
  module Actions
    class ContentViewPublishTest < ActiveSupport::TestCase

      def setup
        @org = Organization.new(:label => 'org')
        @content_view = ContentView.new { |cv| cv.organization = @org }
        @content_view.stubs(:repos).returns([])

        @input = { 'organization_label' => 'ACME',
                   'id' => '123',
                   'label' => 'cv' }
      end

      test "runs unless the environment in foreman is already created " do
        Bindings.stubs(:environment_find).with('ACME', 'Library', 'cv').returns(nil)

        step = run_steps(ContentViewPublish, @input, @content_view).first
        assert_equal ContentViewPublish, step.action_class
        assert_equal step.input, @input

        Bindings.stubs(:environment_find).with('ACME', 'Library', 'cv').returns({'id' => '123'})
        assert_equal [], run_steps(ContentViewPublish, @input, @content_view)
      end

      test "plans repository change action for every repo involved" do
        Bindings.stubs(:environment_find).with('ACME', 'Library', 'cv').returns({'id' => '123'})
        repo = Repository.new
        @content_view.stubs(:repos).returns([repo])

        action_class, arg = planned_actions(ContentViewPublish, @input, @content_view).first
        assert_equal RepositoryChange, action_class
        assert_equal arg, repo
      end

      test 'calls bindings to create environment' do
        Bindings.expects(:environment_create).with('123', 'org', 'Library', 'cv')
        ContentViewPublish.new('organization_label' => 'org', 'label' => 'cv', 'id' => '123').run
      end

    end
  end
end
