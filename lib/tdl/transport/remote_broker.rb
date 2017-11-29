
module TDL
  class RemoteBroker
    def initialize(hostname, port, unique_id, timeout_millis)
      @timeout_millis = timeout_millis
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
      @time_taken_2 = Time.now.to_f
      puts "time = #{@time_taken_2 - @time_taken_1}"
      kill_thread
      serialized_response = @serialization_provider.serialize(response)
      @stomp_client.publish("/queue/#{@unique_id}.resp", serialized_response)
      @stomp_client.acknowledge(request.original_message)
    end

    def join
      start_timer
      @time_taken_1 = Time.now.to_f
      @stomp_client.join
    end

    def close
      @stomp_client.close
    end

    def kill_thread
      @thread.terminate unless @thread.nil?
      @thread = nil
      puts "thread killed"
    end

    def start_timer
      puts "started thread"
      # if @thread.nil?
      #   @thread = Thread.new do
      #     sleep(@timeout_millis / 1000.00)
      #     close
      #   end
      #   puts "created new thread"
      # end
    end
  end
end
