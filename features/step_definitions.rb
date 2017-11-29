require_relative './test_helper'
require 'logging'

Logging.logger.root.appenders = Logging.appenders.stdout

CORRECT_SOLUTION = lambda {|params|
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

# ~~~~~ Setup

Given(/^I start with a clean broker and a client for user "([^\"]*)"$/) do |username|
  unique_id = username
  @request_queue = BROKER.add_queue("#{unique_id}.req")
  @request_queue.purge

  @response_queue = BROKER.add_queue("#{unique_id}.resp")
  @response_queue.purge

  @client = TDL::Client.new(hostname: HOSTNAME, port: STOMP_PORT, unique_id: unique_id)
end

Given(/^the broker is not available$/) do
  @client = TDL::Client.new(hostname: '111', port: STOMP_PORT, unique_id: 'broker')
end

Given(/^I receive 50 identical requests like:$/) do |table|
  50.times do
    table.hashes.each do |row|
      @request_queue.send_text_message(row[:payload])
    end
    @request_count = table.hashes.count
  end
end


Then(/^the time to wait for requests is (\d+)ms$/) do |expected_timeout|
  assert_equal expected_timeout.to_i, @client.get_request_timeout_millis,
               'The client request timeout has a different value.'
end


Then(/^the request queue is "([^"]*)"$/) do |expected_value|
  assert_equal expected_value, @request_queue.get_name,
               'Request queue has a different value.'
end


Then(/^the response queue is "([^"]*)"$/) do |expected_value|
  assert_equal expected_value, @response_queue.get_name,
               'Request queue has a different value.'
end

Then(/^the processing time should be lower than (\d+)ms$/) do |expected_value|
  assert expected_value.to_i > @client.total_processing_time,
         'Request queue has a different value.'
end

Given(/^I receive the following requests:$/) do |table|
  table.hashes.each do |row|
    @request_queue.send_text_message(row[:payload])
  end
  @request_count = table.hashes.count
end

# ~~~~~ Implementations

USER_IMPLEMENTATIONS = {
    'add two numbers' => lambda {|x, y| x + y},
    'return null' => lambda {|*args| nil},
    'throw exception' => lambda {|*args| raise StandardError},
    'some logic' => lambda {:value},
    'increment number' => ->(x) {x + 1},
    'echo the request' => ->(x) {x},
    'work for 600ms' => ->(x) {sleep(0.6); 'OK'},
}

def as_implementation(call)
  if USER_IMPLEMENTATIONS.has_key?(call)
    USER_IMPLEMENTATIONS[call]
  else
    raise "Not a valid implementation reference: \"#{call}\""
  end
end

include TDL::ClientActions
CLIENT_ACTIONS = {
    'publish' => publish,
    'stop' => stop,
    'publish and stop' => publish_and_stop
}

def as_action(actionName)
  if CLIENT_ACTIONS.has_key?(actionName)
    CLIENT_ACTIONS[actionName]
  else
    raise "Not a valid action reference: \"#{actionName}\""
  end
end


When(/^I go live with the following processing rules:$/) do |table|
  processing_rules = TDL::ProcessingRules.new

  table.hashes.each do |row|
    processing_rules.on(row[:method]).call(as_implementation(row[:call])).then(as_action(row[:action]))
  end

  # @captured_io = capture_subprocess_io do
    @client.go_live_with(processing_rules)
  # end
end


# ~~~~~ Assertions

Then(/^the client should consume all requests$/) do
  assert_equal 0, @request_queue.get_size, 'Requests have not been consumed'
end

Then(/^the client should consume first request$/) do
  assert_equal @request_count-1, @request_queue.get_size, 'Requests have not been consumed'
end

Then(/^the client should publish the following responses:$/) do |table|
  assert_equal table.hashes.map {|row| row[:payload]}, @response_queue.get_message_contents, 'The responses are not correct'
end

Then(/^the client should display to console:$/) do |table|
  table.hashes.each do |row|
    assert_includes @captured_io.join(''), row[:output]
  end
end

Then(/^the client should not display to console:$/) do |table|
  table.raw.flatten.each {|row|
    refute_includes @captured_io.join(''), row
  }
end

Then(/^the client should not consume any request$/) do
  assert_equal @request_count, @request_queue.get_size,
               'The request queue has different size. Messages have been consumed'
end

Then(/^the client should not publish any response$/) do
  assert_equal 0, @response_queue.get_size,
               'The response queue has different size. Messages have been published'
end

Then(/^I should get no exception$/) do
  #OBS if you get here there were no exceptions
end
