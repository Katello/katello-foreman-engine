require 'test_helper'

module KatelloForemanEngine
  module Actions
    class DistributionPublishTest < ActiveSupport::TestCase

      def setup
        @input = {
          'family' => 'Red Hat Enterprise Linux',
          'variant' => 'Server',
          'arch' => 'x86_64',
          'version' => '6.3',
          'repo' => {
            'pulp_id' => 'Org-Env-Prod-Repo',
            'uri' => 'http://example.com/pulp/repos/os/',
            'label' => 'Repo',
            'product_label' => 'Prod',
            'environment_label' => 'Env',
            'organization_label' => 'Org'
          }
        }

        @arch = 'x86_64'
        @os_name = 'RedHat'
        @os_major = '6'
        @os_minor = '3'

        @medium_name = 'Org/Env RedHat Server 6.3 x86_64'
        @medium_path = 'http://example.com/pulp/repos/os/'

        @arch_output = {'architecture' => { 'id' => 1, 'name' => @arch }}
        @ptable_output = {'ptable' => { 'id' => 1, 'name' => 'RedHat default' }}
        @organization_output = {
          'organization' => { 'id' => 1 }
        }
        @os_output = {
          'operatingsystem' => {
            'id' => 1,
            'name' => @os_name,
            'major' => @os_major,
            'minor' => @os_minor,
            'family' => 'RedHat',
            'architectures' => [@arch_output],
            'media' => [],
            'ptables' => [@ptable_output],
          }
        }
        @medium_output = {
          'medium' => {
            'id' => 1,
            'name' => @medium_name,
            'path' => @medium_path
          }
        }

        Bindings.stubs(:organization_find).with('Org').returns(@organization_output)
        stub_foreman_search(:architecture, "name = #{@arch}", @arch_output)
        stub_foreman_search(:ptable, %{name = "RedHat default"}, @ptable_output)
        stub_foreman_call(:medium, :index, nil, [])
        stub_foreman_call(:medium, :create, nil, @medium_output)
        stub_foreman_call(:operating_system, :index, nil, [])
        stub_foreman_call(:operating_system, :create, nil, @os_output)
        stub_foreman_call(:operating_system, :update)
        stub_foreman_search(:config_template, %{name = "Katello Kickstart Default for RHEL"}, nil)
        stub_foreman_search(:config_template, %{name = "Kickstart default PXElinux"}, nil)
        stub_foreman_search(:ptable, %{name = "RedHat default"}, nil)
        stub_foreman_call(:operating_system, :index, nil, [])
      end

      def run_action
        action = DistributionPublish.new(@input)
        action.run
        return action
      end

      test "creates architecture in foreman if not created yet" do
        stub_foreman_search(:architecture, "name = #{@arch}", nil)
        expect_foreman_call(:architecture, :create, {'name' => @arch}, @arch_output)
        run_action
      end

      test "creates operating system in foreman if not created yet" do
        stub_foreman_search(:operating_system, "name = #{@os_name} AND major = #{@os_major} AND minor = #{@os_minor}", nil)
        os_data = {
          'name' => @os_name,
          'major' => @os_major.to_s,
          'minor' => @os_minor.to_s,
          'family' => 'Redhat',
          'os_default_templates_attributes' => [],
        }
        expect_foreman_call(:operating_system, :create, os_data, @os_output)
        run_action
      end

      test "creates sets minor version empty if missing" do
        stub_foreman_search(:operating_system, "name = #{@os_name} AND major = #{@os_major} AND minor = ", nil)
        os_data = {
          'name' => @os_name,
          'major' => @os_major.to_s,
          'minor' => '',
          'family' => 'Redhat',
          'os_default_templates_attributes' => [],
        }
        expect_foreman_call(:operating_system, :create, os_data, @os_output)
        @input['version'] = '6'
        run_action
      end

      test "assigns architecture to operating system if not assigned yet" do
        os_without_arch = {
          'operatingsystem' => @os_output['operatingsystem'].merge('architectures' => [])
        }
        stub_foreman_search(:operating_system, "name = #{@os_name} AND major = #{@os_major} AND minor = #{@os_minor}", os_without_arch)
        expected_data = {'id' => 1, 'architecture_ids' => [@arch_output['architecture']['id']]}
        expect_foreman_call(:operating_system, :update,  expected_data)
        run_action
      end

      test "creates medium and assigns it to the os in not created yet" do
        medium_params = {
          'name' => @medium_name,
          'path' => @medium_path,
          'os_family' => 'Redhat',
          'organization_ids' => [1],
        }
        expect_foreman_call(:medium, :create, medium_params, @medium_output)
        expected_data = {'id' => 1, 'medium_ids' => [@medium_output['medium']['id']]}
        expect_foreman_call(:operating_system, :update,  expected_data)
        run_action
      end

      test "it constructs medium name that foreman accepts" do
        action = DistributionPublish.new(@input)
        assert_equal 'Org/Env RedHat Server 6.3 x86_64', action.send(:construct_medium_name)

        @input['variant'] = ''
        @input['arch'] = nil
        assert_equal 'Org/Env RedHat 6.3', action.send(:construct_medium_name)
      end

    end
  end
end
