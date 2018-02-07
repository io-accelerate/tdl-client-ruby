require 'stomp'
require 'tdl/thread_timer'
require 'tdl/queue/serialization/json_rpc_serialization_provider'

module TDL
  class RemoteBroker
    def initialize(hostname, port, unique_id, request_timeout_millis)
      @stomp_client = Stomp::Client.new('', '', hostname, port)
      @unique_id = unique_id
      @request_queue = "/queue/#{@unique_id}.req"
      @response_queue = "/queue/#{@unique_id}.resp"
      @serialization_provider = JSONRPCSerializationProvider.new
      @timer = ThreadTimer.new(request_timeout_millis, lambda = ->() { close unless closed? })
      @timer.start
    end

    def subscribe(handling_strategy)
      @stomp_client.subscribe(@request_queue, {:ack => 'client-individual', 'activemq.prefetchSize' => 1}) do |msg|
        @timer.stop
        request = @serialization_provider.deserialize(msg)
        handling_strategy.process_next_request_from(self, request)
        @timer.start
      end
    end

    def respond_to(request, response)
      serialized_response = @serialization_provider.serialize(response)
      @stomp_client.publish(@response_queue, serialized_response)
      @stomp_client.acknowledge(request.original_message)
    end

    def join
      @stomp_client.join
    end

    def close
      @stomp_client.unsubscribe(@request_queue)
      @stomp_client.close
    end

    def closed?
      @stomp_client.closed?
    end
  end
end
