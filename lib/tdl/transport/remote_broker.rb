module TDL
  class RemoteBroker
    def initialize(hostname, port, unique_id)
      @stomp_client = Stomp::Client.new('', '', hostname, port)
      @unique_id = unique_id
      @serialization_provider = JSONRPCSerializationProvider.new
    end

    def subscribe(handling_strategy)
      @stomp_client.subscribe("/queue/#{@unique_id}.req", {:ack => 'client-individual', 'activemq.prefetchSize' => 1}) do |msg|
        request = @serialization_provider.deserialize(msg)
        handling_strategy.process_next_request_from(self, request)
      end
    end

    def respond_to(request, response)
      serialized_response = @serialization_provider.serialize(response)
      @stomp_client.publish("/queue/#{@unique_id}.resp", serialized_response)
      @stomp_client.acknowledge(request.original_message)
    end

    def join(limit = nil)
      @stomp_client.join(limit)
    end

    def close
      @stomp_client.close
    end
  end
end
