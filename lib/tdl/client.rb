require 'stomp'

module TDL

  class Client

    def initialize(hostname, port, username)
      @stomp_client = Stomp::Client.new('', '', hostname, port)
      @username = username
    end

    def go_live_with(&block)
      @stomp_client.subscribe("/queue/#{@username}.req", {:ack => 'client', 'activemq.prefetchSize' => 1}) do |msg|
        response = do_something(block, msg.body)
        if response == nil
           @stomp_client.close
        end

        @stomp_client.publish("/queue/#{@username}.resp", response)
        @stomp_client.acknowledge(msg)
      end

      #DEBT: We should have no timeout here
      @stomp_client.join(3)
      @stomp_client.close
    end

    # ~~~~ Processing

    def do_something(block, request)
      items = request.split(', ')
      id = items[0]
      items.shift
      params = items

      result = block.call(params)


      processed_req = params.to_s.gsub('"', '')
      puts "id = #{id}, req = #{processed_req}, resp = #{result}"

      "#{id}, #{result}"
    end


  end

end