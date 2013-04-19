require 'test_helper'

class SettingsTest < ActiveSupport::TestCase

  def setup
    #Setting.where(:name => 'katello_url').delete_all
  end

  test "katello specific settings" do
    KatelloForemanEngine::Settings.initialize_settings
    assert_equal 'https://localhost/katello', Setting['katello_url']
  end
end
