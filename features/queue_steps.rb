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
BROKER_NAME = 'localhost'

BROKER = ActiveMQBrokerRule.new(HOSTNAME, JMX_PORT, BROKER_NAME)
BROKER.connect

# Broker client definition
STOMP_PORT = 21613

REQUEST_QUEUE_NAME = 'some-user-req'
RESPONSE_QUEUE_NAME = 'some-user-resp'

# ~~~~~ Setup

Given(/^I start with a clean broker having a request and a response queue$/) do ||
  @request_queue = BROKER.add_queue(REQUEST_QUEUE_NAME)
  @request_queue.purge

  @response_queue = BROKER.add_queue(RESPONSE_QUEUE_NAME)
  @response_queue.purge
end

Given(/^a client that connects to the queues$/) do
  config = TDL::ImplementationRunnerConfig.new()
    .set_hostname(HOSTNAME)
    .set_port(STOMP_PORT)
    .set_request_queue_name(REQUEST_QUEUE_NAME)
    .set_response_queue_name(RESPONSE_QUEUE_NAME)

  @queueBasedImplementationRunnerBuilder = TDL::QueueBasedImplementationRunnerBuilder.new()
    .set_config(config)
  @queueBasedImplementationRunner = @queueBasedImplementationRunnerBuilder.create
end

Given(/^the broker is not available$/) do
  config = TDL::ImplementationRunnerConfig.new()
    .set_hostname('111')
    .set_port(STOMP_PORT)
    .set_request_queue_name('X')
    .set_response_queue_name('Y')

  @queueBasedImplementationRunnerBuilder = TDL::QueueBasedImplementationRunnerBuilder.new()
    .set_config(config);
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
  assert_equal expected_timeout.to_i, @queueBasedImplementationRunner.get_request_timeout_millis,
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
  assert expected_value.to_i > @queueBasedImplementationRunner.total_processing_time,
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
    'replay the value' => ->(x) {x},
    'sum the elements of an array' => ->(x) {x.reduce(0) { |sum, num| sum + num }},
    'generate array of integers' => lambda {|x, y| (x...y).to_a},
    'work for 600ms' => ->(x) {sleep(0.6); 'OK'},
    'concatenate fields as string' => ->(obj) {obj["field1"] + obj["field2"].to_s},
    'build an object with two fields' => ->(field1, field2) {{ "field1" => field1, "field2" => field2 }},
}

def as_implementation(call)
  if USER_IMPLEMENTATIONS.has_key?(call)
    USER_IMPLEMENTATIONS[call]
  else
    raise "Not a valid implementation reference: \"#{call}\""
  end
end


When(/^I go live with the following processing rules:$/) do |table|
  table.hashes.each do |row|
    @queueBasedImplementationRunnerBuilder
      .with_solution_for(
        row[:method],
        as_implementation(row[:call]))
  end

  @queueBasedImplementationRunner = @queueBasedImplementationRunnerBuilder.create

  begin
    @captured_io = capture_subprocess_io do
      @queueBasedImplementationRunner.run
    end
  ensure
    @captured_io.each { |x| puts x }
  end
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

Then(/^the client should consume one request$/) do
  assert_equal @request_count - 1, @request_queue.get_size,
               'The request queue has different size. Messages have been consumed'
end

Then(/^the client should publish one response$/) do
  assert_equal @request_count - 2, @response_queue.get_size,
               'The response queue has different size. Messages have been published'
end

Then(/^I should get no exception$/) do
  #OBS if you get here there were no exceptions
end
