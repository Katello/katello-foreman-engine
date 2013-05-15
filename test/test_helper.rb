require 'rubygems'
require 'bundler/setup'

ENV["RAILS_ENV"] ||= 'test'
require File.join("katello_app/config/environment.rb")

require 'test/unit'
require 'katello-foreman-engine'
require 'rails/test_help'
require 'mocha/setup'

Rails.backtrace_cleaner.remove_silencers!

# returns the subactions being planned from the plan method of
# +action_class+. It prevents calling plan methods on the subactions,
# letting to test only the action_class in isolation.
def planned_actions(action_class, input, *args)
  planned_actions = []
  action = action_class.new(input)
  action.stubs(:plan_action).with do |*args|
    planned_actions << args
  end
  action.plan(*args)
  return planned_actions
end

# returns the run steps planned for given action, given
# input from parent action and *args for plan method
def run_steps(action_class, input, *args)
  action = action_class.new(input)
  action.plan(*args)
  return action.execution_plan.run_steps
end

def expect_foreman_search(*args)
  args = args + [true]
  stub_foreman_search(*args)
end

def stub_foreman_search(resource, search, response, expect = false)
  response = case response
             when nil
               []
             when Array
               response
             else
               [response]
             end
  stub_foreman_call(resource, :index, {'search' => search}, response, expect)
end

def expect_foreman_call(*args)
  args = args + [true]
  stub_foreman_call(*args)
end

def stub_foreman_call(resource, action, request = nil, response = nil, expect = false)
  setup_user
  resource_key = resource.to_s
  # difference between class name and resource key in the API
  resource_key.gsub!('_','') if resource_key == 'operating_system'
  if request && [:create, :update].include?(action) && !request.has_key?(resource_key)
    request = {resource_key => request}
  end
  resource_class ="ForemanApi::Resources::#{resource.to_s.camelize}".constantize
  stub = resource_class.any_instance.stubs(action)
  if request
    stub.with(request)
  end
  if response
    stub.returns([response, response.to_json])
  end
end

def setup_user
  User.current ||= User.new(:username => 'admin')
end
