require 'test_helper'

module KatelloForemanEngine
  module Actions
    class DistributionUnpublishTest < ActiveSupport::TestCase

      def setup
        @https_path = "https://example.com/my/repo"
        @http_path = "http://example.com/my/repo/"
        @medium_output = {'medium' => {'id' => '123'}}
        @repo = stub(:uri => @https_path)
      end

      test "deletes the instalation media using the repo" do
        stub_foreman_search(:medium, %{path = "#{@http_path}"}, @medium_output)
        step = run_steps(DistributionUnpublish, {}, @repo).first
        assert_equal DistributionUnpublish, step.action_class
        assert_equal({'medium_id' => '123'}, step.input)
      end

      test "does nothing if the installation media is not present" do
        stub_foreman_search(:medium, %{path = "#{@http_path}"}, [])
        assert_equal [], run_steps(DistributionUnpublish, {}, @repo)
      end

      test 'calls bindings to destroy environment' do
        expect_foreman_call(:medium, :destroy, {'id' => '123'})
        DistributionUnpublish.new('medium_id' => '123').run
      end

    end
  end
end
