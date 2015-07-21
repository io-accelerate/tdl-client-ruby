# noinspection RubyResolve,RubyResolve
require 'test_helper'

class ClientTest < Minitest::Test
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

  # Broker JMX definition
  HOSTNAME = 'localhost'
  JMX_PORT = 20011
  BROKER_NAME = 'TEST.BROKER'

  @@broker = ActiveMQBrokerRule.new(HOSTNAME, JMX_PORT, BROKER_NAME)
  @@broker.connect

  # Broker client definition
  STOMP_PORT = 21613
  USERNAME = 'test'

  def setup
    # Given we have a couple of requests waiting
    @request_queue = @@broker.add_queue("#{USERNAME}.req")
    @request_queue.purge
    REQUESTS.each { |request| @request_queue.send_text_message(request) }

    # And no responses
    @response_queue = @@broker.add_queue("#{USERNAME}.resp")
    @response_queue.purge

    @client = TDL::Client.new(HOSTNAME, STOMP_PORT, USERNAME)
  end


  def test_if_user_goes_live_client_should_process_all_messages

    @client.go_live_with(&CORRECT_SOLUTION)

    assert_equal 0, @request_queue.get_size, 'Requests have not been consumed'
    assert_equal EXPECTED_RESPONSES, @response_queue.get_message_contents, 'The responses are not correct'
  end


  def test_a_run_should_show_the_messages_and_the_responses

    out = capture_io do
      @client.go_live_with(&CORRECT_SOLUTION)
    end

    # Captured output
    EXPECTED_DISPLAYED_TEXT.each { |expected_line|
      assert_list_contains(expected_line, out)
    }
  end

  # Helpers

  def assert_list_contains(expected_substring, list)
    matches = list.select { |line| line.include? expected_substring }.count
    assert matches == 1, "Expected #{list} to contain: \"#{expected_substring}\""
  end

end