require 'test_helper'

class ClientTest < MiniTest::Unit::TestCase
  EXPECTED_RESPONSES = 'x'

  def setup
    @requestQueue = RemoteJmxQueue.new
    @responseQueue = RemoteJmxQueue.new
    @client = TDL::Client.new
  end

  def test_if_user_goes_live_client_should_process_all_messages

    @client.go_live_with { |x,y| x + y }

    assert_equal 0, @requestQueue.get_size, 'Requests have not been consumed'
    assert_equal EXPECTED_RESPONSES, @responseQueue.get_message_contents, 'The responses are not correct'
  end
end