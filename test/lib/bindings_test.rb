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
    config = KatelloForemanEngine::Bindings.environment.config
    assert_equal 'https://example.com/foreman', config[:base_url]
    assert_equal 'key', config[:oauth][:consumer_key]
    assert_equal 'secret', config[:oauth][:consumer_secret]
  end

end
