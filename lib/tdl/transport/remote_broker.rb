module TDL
  class RemoteBroker
    def initialize(hostname, port, username)
      @stomp_client = Stomp::Client.new('', '', hostname, port)
      @username = username
      @serialization_provider = JSONRPCSerializationProvider.new
    end

    def subscribe(handling_strategy)
      @stomp_client.subscribe("/queue/#{@username}.req", {:ack => 'client', 'activemq.prefetchSize' => 1}) do |msg|
        request = @serialization_provider.deserialize(msg)
        handling_strategy.process_next_request_from(self, request)
      end
    end

    def respond_to(request, response)
      serialized_response = @serialization_provider.serialize(response)
      @stomp_client.publish("/queue/#{@username}.resp", serialized_response)
      @stomp_client.acknowledge(request.original_message)
    end

    def publish(response)
      @stomp_client.publish("/queue/#{@username}.resp", response)
    end

    def join(limit = nil)
      @stomp_client.join(limit)
    end

    def close
      @stomp_client.close
    end
  end
end
