module TDL
  class RemoteBroker
    def initialize(hostname, port, username)
      @stomp_client = Stomp::Client.new('', '', hostname, port)
      @username = username
    end


    def subscribe(handling_strategy)
      @stomp_client.subscribe("/queue/#{@username}.req", {:ack => 'client', 'activemq.prefetchSize' => 1}) do |msg|
        handling_strategy.process_next_message_from(self, msg)
      end
    end

    def acknowledge(msg)
      @stomp_client.acknowledge(msg)
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