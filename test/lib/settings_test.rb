require 'test_helper'

class SettingsTest < ActiveSupport::TestCase

  test "katello specific settings" do
    KatelloForemanEngine::Settings.initialize_settings
    assert_equal 'https://localhost/foreman', KatelloForemanEngine::Settings['foreman_url']
  end

end
