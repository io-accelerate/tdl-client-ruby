require 'stomp'
require 'logging'

require 'tdl/transport/remote_broker'
require 'tdl/abstractions/processing_rules'
require 'tdl/actions/stop_action'

require 'tdl/serialization/json_rpc_serialization_provider'

module TDL

  class Client

    def initialize(hostname, port, username)
      @hostname = hostname
      @port = port
      @username = username
      @logger = Logging.logger[self]
    end

    def go_live_with(processing_rules)
      begin
        @logger.info 'Starting client.'
        remote_broker = RemoteBroker.new(@hostname, @port, @username)
        remote_broker.subscribe(ApplyProcessingRules.new(processing_rules))

        #DEBT: We should have no timeout here. We could put a special message in the queue
        remote_broker.join(3)
        @logger.info 'Stopping client.'
        remote_broker.close
      rescue Exception => e
        @logger.error "Problem communicating with the broker. #{e.message}"
        raise $! if ENV['RUBY_ENV'] == 'test'
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
        processing_rule = @processing_rules.get_rule_for(request)
        response = get_response_for(processing_rule, request)
        @audit.log(response ? response : Response.new('','empty'))

        # Obtain action
        client_action = response ? processing_rule.client_action : StopAction.new

        # Act
        client_action.after_response(remote_broker, request, response)
        @audit.log(client_action)
        @audit.end_line
        client_action.prepare_for_next_request(remote_broker)
      end

      def get_response_for(processing_rule, request)
        begin
          user_implementation = processing_rule.user_implementation
          result = user_implementation.call(*request.params)

          response = Response.new(request.id, result)
        rescue Exception => e
          response = nil
          @logger.info "The user implementation has thrown exception. #{e.message}"
        end
        response
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
