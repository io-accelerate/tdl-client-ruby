
module TDL

  class Client

    def initialize(broker_url, username)

      @stomp_client = Stomp::Client.new("", "", "localhost", 21613)
      @username = username
    end

    def go_live_with(&block)
      puts block.inspect
      @stomp_client.subscribe("/queue/#{@username}.req", {:ack => 'client', 'activemq.prefetchSize' => 1}) do |msg|

        p msg.body
        @stomp_client.acknowledge(msg)

        #If problems we can @stomp_client.close()
      end

      #DEBT: We should have no timeout here
      @stomp_client.join(3)
      @stomp_client.close()
    end
  end

end