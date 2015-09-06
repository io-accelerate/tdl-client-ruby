require 'stomp'
require 'logging'

require 'tdl/transport/remote_broker'
require 'tdl/deserialize_and_respond_to_message'

module TDL

  class Client

    def initialize(hostname, port, username)
      @hostname = hostname
      @port = port
      @username = username
      @logger = Logging.logger[self]
    end

    def go_live_with(&user_implementation)
      run(RespondToAllRequests.new(DeserializeAndRespondToMessage.using(user_implementation)))
    end

    def trial_run_with(&user_implementation)
      run(PeekAtFirstRequest.new(DeserializeAndRespondToMessage.using(user_implementation)))
    end

    def run(handling_strategy)
      begin
        @logger.info 'Starting client.'
        remote_broker = RemoteBroker.new(@hostname, @port, @username)
        remote_broker.subscribe(handling_strategy)

        #DEBT: We should have no timeout here. We could put a special message in the queue
        remote_broker.join(3)
        @logger.info 'Stopping client.'
        remote_broker.close
      rescue Exception => e
        @logger.error "Problem communicating with the broker. #{e.message}"
      end
    end

    #~~~~ Queue handling policies

    class RespondToAllRequests
      def initialize(message_handler)
        @message_handler = message_handler
      end

      def process_next_message_from(remote_broker, msg)
        response = @message_handler.respond_to(msg.body)
        if response.nil?
          remote_broker.close
        else
          remote_broker.publish(response)
          remote_broker.acknowledge(msg)
        end
      end
    end

    class PeekAtFirstRequest
      def initialize(message_handler)
        @message_handler = message_handler
      end

      def process_next_message_from(remote_broker, msg)
        @message_handler.respond_to(msg.body)
        remote_broker.close
      end
    end

  end
end