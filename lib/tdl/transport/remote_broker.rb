require_relative '../thread_timer'

module TDL
  class RemoteBroker
    def initialize(hostname, port, unique_id, request_timeout_millis)
      @stomp_client = Stomp::Client.new('', '', hostname, port)
      @unique_id = unique_id
      @serialization_provider = JSONRPCSerializationProvider.new
      @timer_thread = ThreadTimer.new(request_timeout_millis, lambda = ->() { close })
    end

    def subscribe(handling_strategy)
      @stomp_client.subscribe("/queue/#{@unique_id}.req", {:ack => 'client-individual', 'activemq.prefetchSize' => 1}) do |msg|
        @timer_thread.stop_timer
        request = @serialization_provider.deserialize(msg)
        handling_strategy.process_next_request_from(self, request)
        @timer_thread.start_timer
      end
    end

    def respond_to(request, response)
      serialized_response = @serialization_provider.serialize(response)
      @stomp_client.publish("/queue/#{@unique_id}.resp", serialized_response)
      @stomp_client.acknowledge(request.original_message)
    end

    def join
      @timer_thread.start_timer
      @stomp_client.join
    end

    def close
      @stomp_client.close
    end

    def closed?
      @stomp_client.closed?
    end
  end
end
