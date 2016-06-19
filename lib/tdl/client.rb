require 'stomp'
require 'logging'

require 'tdl/transport/remote_broker'
require 'tdl/processing_rules'
require 'tdl/actions/stop_action'

require 'tdl/serialization/json_rpc_serialization_provider'
module TDL

  class Client

    def initialize(hostname:, port: 61613, unique_id:)
      @hostname = hostname
      @port = port
      @unique_id = unique_id
      @logger = Logging.logger[self]
    end

    def go_live_with(processing_rules)
      begin
        @logger.info 'Starting client.'
        remote_broker = RemoteBroker.new(@hostname, @port, @unique_id)
        remote_broker.subscribe(ApplyProcessingRules.new(processing_rules))

        #DEBT: We should have no timeout here. We could put a special message in the queue
        remote_broker.join(3)
        @logger.info 'Stopping client.'
        remote_broker.close
      rescue Exception => e
        # raise e if ENV['TDL_ENV'] == 'test'
        @logger.error "There was a problem processing messages. #{e.message}"
        @logger.error e.backtrace.join("\n")
      end
    end


    #~~~~ Queue handling policies

    class ApplyProcessingRules

      def initialize(processing_rules)
        @processing_rules = processing_rules
        @logger = Logging.logger[self]
        @audit = AuditStream.new
      end

      def process_next_request_from(remote_broker, request)
        @audit.start_line
        @audit.log(request)

        # Obtain response from user
        response = @processing_rules.get_response_for(request)
        @audit.log(response)

        # Obtain action
        client_action = response.client_action

        # Act
        client_action.after_response(remote_broker, request, response)
        @audit.log(client_action)
        @audit.end_line
        client_action.prepare_for_next_request(remote_broker)
      end

    end
  end


  # ~~~~ Utils

  class AuditStream

    def initialize
      @logger = Logging.logger[self]
      start_line
    end

    def start_line
      @str = ''
    end

    def log(auditable)
      text = auditable.audit_text
      if not text.empty? and @str.length > 0
        @str << ', '
      end

      @str << text
    end

    def end_line
      @logger.info @str
    end

  end
end
