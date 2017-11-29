
module TDL
  class RemoteBroker
    def initialize(hostname, port, unique_id, timeout_millis)
      @timeout_millis = timeout_millis
      @stomp_client = Stomp::Client.new('', '', hostname, port)
      @unique_id = unique_id
      @serialization_provider = JSONRPCSerializationProvider.new
      start_timer
    end

    def subscribe(handling_strategy)
      @stomp_client.subscribe("/queue/#{@unique_id}.req", {:ack => 'client-individual', 'activemq.prefetchSize' => 1}) do |msg|
        request = @serialization_provider.deserialize(msg)
        handling_strategy.process_next_request_from(self, request)
      end
      restart_timer
    end

    def respond_to(request, response)
      serialized_response = @serialization_provider.serialize(response)
      @stomp_client.publish("/queue/#{@unique_id}.resp", serialized_response)
      @stomp_client.acknowledge(request.original_message)
      restart_timer
    end

    def join(limit_millis = nil)
      limit_millis.nil? ? @stomp_client.join : @stomp_client.join(limit_millis / 1000.00)
    end

    def close
      @stomp_client.close
    end

    def restart_timer
      @thread.exit
      start_timer
    end

    def start_timer
      @thread = Thread.new do
        sleep(@timeout_millis / 1000.00)
        close
      end
    end
  end
end
