require_relative "./test_helper"
require 'logging'

Logging.logger.root.appenders = Logging.appenders.stdout

REQUESTS = [ 'X1, 0, 1', 'X2, 5, 6' ]
EXPECTED_RESPONSES = ['X1, 1', 'X2, 11']
FIRST_EXPECTED_TEXT  = 'id = X1, req = [0, 1], resp = 1'
SECOND_EXPECTED_TEXT = 'id = X2, req = [5, 6], resp = 11'
EXPECTED_DISPLAYED_TEXT = [ FIRST_EXPECTED_TEXT, SECOND_EXPECTED_TEXT ]

CORRECT_SOLUTION = lambda { |params|
  x = params[0].to_i
  y = params[1].to_i
  x + y
}

# Jolokia JMX definition
HOSTNAME = 'localhost'
JMX_PORT = 28161
BROKER_NAME = 'TEST.BROKER'

BROKER = ActiveMQBrokerRule.new(HOSTNAME, JMX_PORT, BROKER_NAME)
BROKER.connect

# Broker client definition
STOMP_PORT = 21613
USERNAME = 'test'

Given(/^I start with a clean broker$/) do
  @request_queue = BROKER.add_queue("#{USERNAME}.req")
  @request_queue.purge

  @response_queue = BROKER.add_queue("#{USERNAME}.resp")
  @response_queue.purge

  @client = TDL::Client.new(HOSTNAME, STOMP_PORT, USERNAME)
end

Given(/^I receive the following requests:$/) do |table|
  table.raw.each { |request|
    @request_queue.send_text_message(request)
  }
  @request_count = table.raw.count
end

When(/^I go live with an implementation that adds two numbers$/) do
  @captured_io = capture_subprocess_io do
    @client.go_live_with(&CORRECT_SOLUTION)
  end
end

Then(/^the client should consume all requests$/) do
  assert_equal 0, @request_queue.get_size, 'Requests have not been consumed'
end

Then(/^the client should publish the following responses:$/) do |table|
  assert_equal table.raw.flatten, @response_queue.get_message_contents, 'The responses are not correct'
end

Then(/^the client should display to console:$/) do |table|
  table.raw.flatten.each { |row|
    assert_includes @captured_io.join(""), row
  }
end

When(/^I go live with an implementation that returns null$/) do
  @client.go_live_with { nil }
end

Then(/^the client should not consume any request$/) do
  assert_equal @request_queue.get_size, @request_count,
               'The request queue has different size. Messages have been consumed'
end

Then(/^the client should not publish any response$/) do
  assert_equal @response_queue.get_size, 0,
               'The response queue has different size. Messages have been published'
end

When(/^I go live with an implementation that throws exception$/) do
  @client.go_live_with { raise StandardError }
end

Given(/^the broker is not available$/) do
  @client_without_broker = TDL::Client.new("#{HOSTNAME}1", STOMP_PORT, 'broker')
end

When(/^I go live with an implementation that is valid$/) do
  @client.go_live_with { :value }
end

Then(/^I should get no exception$/) do
  #OBS if you get here there were no exceptions
end

When(/^I do a trial run with an implementation that adds two numbers$/) do
  @captured_io = capture_subprocess_io do
    @client.trial_run_with(&CORRECT_SOLUTION)
  end
end

Then(/^the client should not display to console:$/) do |table|
  table.raw.flatten.each { |row|
    refute_includes @captured_io.join(""), row
  }
end
