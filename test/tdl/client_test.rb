# noinspection RubyResolve,RubyResolve
require 'test_helper'

class ClientTest < Minitest::Test
  REQUESTS = [ 'X1, 0, 1', 'X2, 5, 6' ]
  EXPECTED_RESPONSES = 'x'
  CORRECT_SOLUTION = lambda { |x,y| x + y }

  # Broker JMX definition
  JMX_PORT = 20011
  BROKER_NAME = 'TEST.BROKER'
  @@broker = ActiveMQBrokerRule.new('localhost', JMX_PORT, BROKER_NAME)
  @@broker.connect

  # Broker client definition
  OPENWIRE_PORT = 21616
  BROKER_URL = "tcp://localhost:#{OPENWIRE_PORT}"
  USERNAME = 'test'

  def setup
    # Given we have a couple of requests waiting
    @request_queue = @@broker.add_queue("#{USERNAME}.req")
    @request_queue.purge
    REQUESTS.each { |request| @request_queue.send_text_message(request) }

    # And no responses
    @response_queue = @@broker.add_queue("#{USERNAME}.resp")
    @response_queue.purge

    @client = TDL::Client.new(BROKER_URL, USERNAME)
  end


  def test_if_user_goes_live_client_should_process_all_messages

    @client.go_live_with(&CORRECT_SOLUTION)

    assert_equal 0, @request_queue.get_size, 'Requests have not been consumed'
    assert_equal EXPECTED_RESPONSES, @response_queue.get_message_contents, 'The responses are not correct'
  end

end