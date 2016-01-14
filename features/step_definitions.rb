require_relative './test_helper'
require 'logging'

Logging.logger.root.appenders = Logging.appenders.stdout

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

# ~~~~~ Setup

Given(/^I start with a clean broker$/) do
  @request_queue = BROKER.add_queue("#{USERNAME}.req")
  @request_queue.purge

  @response_queue = BROKER.add_queue("#{USERNAME}.resp")
  @response_queue.purge

  @client = TDL::Client.new(HOSTNAME, STOMP_PORT, USERNAME)
end

Given(/^the broker is not available$/) do
  @client_without_broker = TDL::Client.new("#{HOSTNAME}1", STOMP_PORT, 'broker')
end

Given(/^I receive the following requests:$/) do |table|
  table.raw.each { |request|
    @request_queue.send_text_message(request.first)
  }
  @request_count = table.raw.count
end

# ~~~~~ Implementations

IMPLEMENTATION_MAP = {
    'add two numbers' => lambda { |x, y|
      # x = params[0].to_i
      # y = params[1].to_i
      x + y
      # ->(x, y){x.to_i + y.to_i}
    },
    'return null' => lambda { |*args| nil },
    'throw exception' => lambda { |*args| raise StandardError },
    'some logic' => lambda { :value },
    'increment number' => ->(x){ x + 1 }
}

# Not necessary use hash.fetch(key)
def get_lambda(name)
  if IMPLEMENTATION_MAP.has_key?(name)
    IMPLEMENTATION_MAP[name]
  else
    raise "Not a valid implementation reference: \"#{name}\""
  end
end

When(/^I go live with the following processing rules:$/) do |table|
  processing_rules = TDL::ProcessingRules.new

  table.hashes.each do |row|
    implementation = IMPLEMENTATION_MAP.fetch(row[:Call])
    processing_rules.add(row[:Method], implementation, row[:Action])
  end

  @captured_io = capture_subprocess_io do
    @client.go_live_with(processing_rules)
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
  assert_equal table.raw.flatten, @response_queue.get_message_contents, 'The responses are not correct'
end

Then(/^the client should display to console:$/) do |table|
  table.raw.flatten.each { |row|
    assert_includes @captured_io.join(''), row
  }
end

Then(/^the client should not display to console:$/) do |table|
  table.raw.flatten.each { |row|
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
