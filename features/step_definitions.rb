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
    @request_queue.send_text_message(request)
  }
  @request_count = table.raw.count
end

# ~~~~~ Implementations

IMPLEMENTATION_MAP = {
    'adds two numbers' => lambda { |x, y|
      # x = params[0].to_i
      # y = params[1].to_i
      x + y
      # ->(x, y){x.to_i + y.to_i}
    },
    'returns null' => lambda { nil },
    'throws exception' => lambda { raise StandardError },
    'is valid' => lambda { :value },
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

When(/^I go live with the following implementations:$/) do |table|
  method_map = table.raw.each_with_object({}) do |(method_name, implementation_name), out|
    out[method_name] = IMPLEMENTATION_MAP.fetch(implementation_name)
  end

  @captured_io = capture_subprocess_io do
    @client.go_live_with(OpenStruct.new(method_map))
  end

end

When(/^I do a trial run with the following implementations:$/) do |table|
  # table is a Cucumber::Core::Ast::DataTable
  pending # Write code here that turns the phrase above into concrete actions
end


# ~~~~~ Assertions

Then(/^the client should consume all requests$/) do
  assert_equal 0, @request_queue.get_size, 'Requests have not been consumed'
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
  assert_equal @request_queue.get_size, @request_count,
               'The request queue has different size. Messages have been consumed'
end

Then(/^the client should not publish any response$/) do
  assert_equal @response_queue.get_size, 0,
               'The response queue has different size. Messages have been published'
end

Then(/^I should get no exception$/) do
  #OBS if you get here there were no exceptions
end
