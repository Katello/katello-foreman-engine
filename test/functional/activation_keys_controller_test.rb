require 'test_helper'
require 'mocha/setup'

class ActivationKeysControllerTest < ActionController::TestCase

  def aks_to_subscriptions_data
    {"ak1" => ["prod1", "prod2"], "ak2" => ["prod3", "prod4"]}
  end

  def test_index
    KatelloForemanEngine::Bindings.stubs(:activation_keys_to_subscriptions).returns(aks_to_subscriptions_data)
    get :index, {}, set_session_user
    assert_response :success
    assert_equal aks_to_subscriptions_data, JSON.parse(response.body)
  end

end
