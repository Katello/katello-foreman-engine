require 'test_helper'

module KatelloForemanEngine
  module Actions
    class RepositoryChangeTest < ActiveSupport::TestCase

      def setup
        @repo_with_distros = stub(:unprotected => true,
                                  :distributions => [stub('family'  => 'Family',
                                                          'variant' => 'Variant',
                                                          'arch'    => 'Arch',
                                                          'version' => 'Version')],
                                  :pulp_id => 'pulp_id',
                                  :uri     => 'https://example.com/repo/uri',
                                  :label   => 'label',
                                  :product => stub(:label => 'product_label'),
                                  :content_view => stub(:default? => true, :label => 'cv'),
                                  :environment => stub(:label => 'environment_label'),
                                  :organization => stub(:label => 'organization_label'))

        @expected_publish_input = {
          "repo"=>
          {
            "pulp_id"=>"pulp_id",
            "uri"=>"https://example.com/repo/uri",
            "label"=>"label",
            "product_label"=>"product_label",
            "environment_label"=>"environment_label",
            "organization_label"=>"organization_label"
          },
          "family"=>"Family",
          "variant"=>"Variant",
          "arch"=>"Arch",
          "version"=>"Version"
        }
      end

      test "plans repository unpublish if no distros found for the repo" do
        repo = stub(:distributions => [])
        action_class, arg = planned_actions(RepositoryChange, {}, repo).first
        assert_equal DistributionUnpublish, action_class
        assert_equal repo, arg
      end

      test "plans distribution publish if repo is unprotected and has distirbutions" do
        action_class, input = planned_actions(RepositoryChange, {}, @repo_with_distros).first
        assert_equal DistributionPublish, action_class
        assert_equal @expected_publish_input, input
      end

      test "passes the content view label unless repo in default content view" do
        @repo_with_distros.content_view.stubs(:default? => false)
        action_class, input = planned_actions(RepositoryChange, {}, @repo_with_distros).first
        assert_equal DistributionPublish, action_class
        @expected_publish_input['repo']['content_view_label'] = 'cv'
        assert_equal input, @expected_publish_input
      end

    end
  end
end
