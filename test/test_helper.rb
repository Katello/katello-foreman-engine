require 'rubygems'
require 'bundler/setup'

ENV["RAILS_ENV"] ||= 'test'
require File.join("katello_app/config/environment.rb")

require 'test/unit'
require 'katello-foreman-engine'
require 'rails/test_help'
require 'mocha/setup'

Rails.backtrace_cleaner.remove_silencers!

# returns the execution plan for given action, given
# input from parent action and *args for plan method
def prepare_plan(action_class, input, *args)
  action = action_class.new(input)
  action.plan(*args)
  return action.execution_plan
end
