require 'stomp'
require 'logging'

module TDL

  class Client

    def initialize(hostname, port, username)
      @hostname = hostname
      @port = port
      @username = username
      @logger = Logging.logger[self]
    end

    def go_live_with(&user_implementation)
      run(false, &user_implementation)
    end

    def trial_run_with(&user_implementation)
      run(true, &user_implementation)
    end

    def run(is_trial_run, &user_implementation)
      begin
        stomp_client = Stomp::Client.new('', '', @hostname, @port)
        stomp_client.subscribe("/queue/#{@username}.req", {:ack => 'client', 'activemq.prefetchSize' => 1}) do |msg|
          response = do_something(user_implementation, msg.body)
          puts "Check this-> #{response}, #{response.nil?}"
          if response.nil?
            stomp_client.close
          else
            stomp_client.publish("/queue/#{@username}.resp", response)
            stomp_client.acknowledge(msg)
          end
        end

        #DEBT: We should have no timeout here
        @logger.info 'Stopping client.'
        stomp_client.join(3)
        stomp_client.close
      rescue Exception => e
        @logger.error "Problem communicating with the broker. #{e.message}"
      end
    end

    # ~~~~ Processing

    def do_something(user_implementation, request)
      items = request.split(', ')
      id = items[0]
      items.shift
      params = items

      begin
        result = user_implementation.call(params)
      rescue Exception => e
        @logger.info "The user implementation has thrown exception. #{e.message}"
        result = nil
      end

      if result.nil?
        @logger.info 'User implementation has returned "nil"'
      end

      processed_req = params.to_s.gsub('"', '')
      @logger.info "id = #{id}, req = #{processed_req}, resp = #{result}"

      (result == nil) ? nil : "#{id}, #{result}"
    end


  end

end