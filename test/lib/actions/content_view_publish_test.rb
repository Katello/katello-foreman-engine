require 'test_helper'

module KatelloForemanEngine
  module Actions
    class ContentViewPublishTest < ActiveSupport::TestCase

      def setup
        @org = Organization.new(:label => 'ACME')
        @content_view = ContentView.new(:label => 'cv', :id => '123') do |cv|
          cv.organization = @org
        end
        @content_view.stubs(:repos).returns([])
      end

      test "runs unless the environment in foreman is already created " do
        Bindings.stubs(:environment_find).with('ACME', 'Library', 'cv').returns(nil)

        step = run_steps(ContentViewPublish, {}, @content_view).first
        assert_equal ContentViewPublish, step.action_class
        assert_equal 'cv', step.input['label']
        assert_equal 'ACME', step.input['organization_label']

        Bindings.stubs(:environment_find).with('ACME', 'Library', 'cv').returns({'id' => '123'})
        assert_equal [], run_steps(ContentViewPublish, {}, @content_view)
      end

      test "plans repository change action for every repo involved" do
        Bindings.stubs(:environment_find).with('ACME', 'Library', 'cv').returns({'id' => '123'})
        repo = Repository.new
        @content_view.stubs(:repos).returns([repo])

        action_class, arg = planned_actions(ContentViewPublish, {}, @content_view).first
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
