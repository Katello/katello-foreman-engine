require 'test_helper'
require 'mocha/setup'

class BindingsTest < ActiveSupport::TestCase

  def setup
    KatelloForemanEngine::Settings.initialize_settings
  end

  test 'client lib setting' do
    KatelloForemanEngine::Settings['foreman_url'] = 'https://example.com/foreman'
    KatelloForemanEngine::Settings['oauth_consumer_key'] = 'key'
    KatelloForemanEngine::Settings['oauth_consumer_secret'] = 'secret'
    User.current = User.new(:username => 'test')
    env_resource = KatelloForemanEngine::Bindings.environment
    config = env_resource.config
    assert_equal 'https://example.com/foreman', config[:base_url]
    assert_equal 'key', config[:oauth][:consumer_key]
    assert_equal 'secret', config[:oauth][:consumer_secret]
    assert_equal 'test', env_resource.client.options[:headers][:foreman_user]
  end

end
