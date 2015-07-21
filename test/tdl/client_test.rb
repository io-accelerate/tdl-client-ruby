# noinspection RubyResolve,RubyResolve
require 'test_helper'
require 'logging'

Logging.logger.root.appenders = Logging.appenders.stdout

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

  #~~~~~ Go live

  def test_if_user_goes_live_client_should_process_all_messages

    @client.go_live_with(&CORRECT_SOLUTION)

    assert_equal 0, @request_queue.get_size, 'Requests have not been consumed'
    assert_equal EXPECTED_RESPONSES, @response_queue.get_message_contents, 'The responses are not correct'
  end


  def test_a_run_should_show_the_messages_and_the_responses

    out = capture_subprocess_io do
      @client.go_live_with(&CORRECT_SOLUTION)
    end

    EXPECTED_DISPLAYED_TEXT.each { |expected_line|
      assert_list_contains(expected_line, out)
    }
  end

  def test_returning_null_from_user_method_should_stop_all_processing

    @client.go_live_with { || nil }

    assert_queues_are_untouched
  end

  def test_throwing_exceptions_from_user_method_should_stop_all_processing

    @client.go_live_with { || raise StandardError }

    assert_queues_are_untouched
  end

  def test_exit_gracefully_if_broker_not_available
    @client = TDL::Client.new("#{HOSTNAME}1", STOMP_PORT, 'broker')

    @client.go_live_with(&CORRECT_SOLUTION)

    # No exception
  end

  #~~~~ Trial run

  def test_a_trial_run_should_only_show_the_first_message_and_the_response

    out = capture_subprocess_io do
      @client.trial_run_with(&CORRECT_SOLUTION)
    end

    assert_list_contains(FIRST_EXPECTED_TEXT, out)
    refute_list_contains(SECOND_EXPECTED_TEXT, out)
  end

  def test_if_user_does_a_trial_run_should_not_consume_or_publish_any_messages

    @client.trial_run_with(&CORRECT_SOLUTION)

    assert_queues_are_untouched
  end

  #~~~~ Utils

  def assert_queues_are_untouched
    assert_equal @request_queue.get_size, REQUESTS.count,
                 'The request queue has different size. Messages have been consumed'
    assert_equal @response_queue.get_size, 0,
                 'The response queue has different size. Messages have been published'

  end

  def assert_list_contains(expected_substring, list)
    matches = count_occurrences(expected_substring, list)
    assert_equal 1, matches, "Expected #{list} to contain: \"#{expected_substring}\""
  end

  def refute_list_contains(expected_substring, list)
    matches = count_occurrences(expected_substring, list)
    refute_equal 1, matches, "Not expecting #{list} to contain: \"#{expected_substring}\""
  end

  def count_occurrences(expected_substring, list)
    matches = list.select { |line| line.include? expected_substring }.count
  end
end