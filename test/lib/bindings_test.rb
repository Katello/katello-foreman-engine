require 'test_helper'
require 'mocha/setup'

class BindingsTest < ActiveSupport::TestCase

  def setup
    Foreman::DefaultSettings::Loader.load
    KatelloForemanEngine::Settings.initialize_settings
  end

  test 'client lib setting' do
    Setting['katello_url'] = 'https://example.com/katello'
    Setting['oauth_consumer_key'] = 'key'
    Setting['oauth_consumer_secret'] = 'secret'
    config = KatelloForemanEngine::Bindings.environment.config
    assert_equal 'https://example.com/katello', config[:base_url]
    assert_equal 'key', config[:oauth][:consumer_key]
    assert_equal 'secret', config[:oauth][:consumer_secret]
  end

  test 'activation keys to subscriptions mapping' do
    KatelloApi::Resources::Environment.any_instance.
      expects(:index).
      with('organization_id' => 'ACME_Corporation', 'name' => 'Dev').
      returns([environments_data, environments_data.to_json])

    KatelloApi::Resources::ActivationKey.any_instance.
      expects(:index).
      with('environment_id' => 2).
      returns([activation_keys_data, activation_keys_data.to_json])

    expected_mapping = {"katello-and-friends-dev" => ["Katello", "Candlepin", "Pulp", "Foreman"]}
    mapping = KatelloForemanEngine::Bindings.activation_keys_to_subscriptions('ACME_Corporation', 'Dev')
    assert_equal(expected_mapping, mapping)
  end

  def environments_data
    [
     {"updated_at"=>"2013-03-08T13:26:56Z",
       "created_at"=>"2013-03-08T13:26:56Z",
       "name"=>"Dev",
       "prior"=>"Library",
       "prior_id"=>1,
       "library"=>false,
       "organization_id"=>1,
       "description"=>"",
       "id"=>2,
       "organization"=>"ACME_Corporation",
       "label"=>"Dev"},
    ]
  end

  def activation_keys_data
    [
     {"name"=>"katello-and-friends-dev",
       "description"=>"",
       "user_id"=>1,
       "created_at"=>"2013-03-08T14:23:06Z",
       "system_template_id"=>nil,
       "updated_at"=>"2013-03-13T13:59:38Z",
       "id"=>1,
       "organization_id"=>1,
       "usage_limit"=>-1,
       "pools"=>
       [{"cp_id" => "8a90c4ae3d49de9b013d5dab8019004a", "productName" => "Katello"},
        {"cp_id" => "8a90c4ae3d49de9b013d5dabc862004d", "productName" => "Candlepin"},
        {"cp_id" => "8a90c4ae3d49de9b013d62d38e340071", "productName" => "Pulp"},
        {"cp_id" => "8a90c4ae3d49de9b013d62d163e9006d", "productName" => "Foreman"}],
       "content_view_id"=>nil,
       "environment_id"=>2,
       "usage_count"=>2},
    ]
  end
end
