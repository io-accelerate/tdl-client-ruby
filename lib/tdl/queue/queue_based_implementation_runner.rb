require 'logging'
require 'tdl/queue/processing_rules'
require 'tdl/queue/transport/remote_broker'

module TDL
    class QueueBasedImplementationRunner
        
        def initialize(config, deploy_processing_rules)
            @config = config
            @deploy_processing_rules = deploy_processing_rules
            @logger = Logging.logger[self]
            @total_processing_time = nil
        end

        def run
            time1 = Time.now.to_f
            begin
                @logger.info 'Starting client'
                remote_broker = RemoteBroker.new(
                    @config.get_hostname,
                    @config.get_port,
                    @config.get_request_queue_name,
                    @config.get_response_queue_name,
                    @config.get_time_to_wait_for_requests)
                remote_broker.subscribe(ApplyProcessingRules.new(@deploy_processing_rules))
                @logger.info 'Waiting for requests.'
                remote_broker.join
                @logger.info 'Stopping client'

            rescue Exception => e
                @logger.error "There was a problem processing messages. #{e.message}"
                @logger.error e.backtrace.join("\n")
            end

            time2 = Time.now.to_f
            @total_processing_time = (time2 - time1) * 1000.00
        end

        def get_request_timeout_millis
            @config.get_time_to_wait_for_requests
        end

        def total_processing_time
            @total_processing_time
        end

        class ApplyProcessingRules

            def initialize(processing_rules)
              @processing_rules = processing_rules
              @logger = Logging.logger[self]
              @audit = AuditStream.new
            end
      
            def process_next_request_from(remote_broker, request)
              @audit.start_line
              @audit.log_request(request)
      
              # Obtain response from user
              response = @processing_rules.get_response_for(request)
              @audit.log_response(response)

              # Act
              after_response(remote_broker, request, response)

              @audit.end_line

              prepare_for_next_request(remote_broker, response)
            end

            def after_response(remote_broker, request, response)
              if response.instance_of? FatalErrorResponse
                 # Do nothing
              else
                 remote_broker.respond_to(request, response)
              end
            end

            def prepare_for_next_request(remote_broker, response)
                if response.instance_of? FatalErrorResponse
                   remote_broker.close
                else
                   # Do nothing
                end
            end
        end
    end
end

class AuditStream

    def initialize
      @logger = Logging.logger[self]
      start_line
    end

    def start_line
      @str = ''
    end

    def log_request(request)
      text =  "id = #{request.id}, req = #{request.method}(#{request.params.map{ |param|
        TDL::Util.compress_data(param)
      }.join(', ')})"
      
      if not text.empty? and @str.length > 0
        @str << ', '
      end
      @str << text
    end

    def log_response(response)
      if response.instance_variable_defined?(:@result)
        text = "resp = #{TDL::Util.compress_data(response.result)}"
      else
        text = "error = #{response.message}" + ", (NOT PUBLISHED)"
      end
      
      if not text.empty? and @str.length > 0
        @str << ', '
      end
      @str << text
    end

    def end_line
      @logger.info @str
    end

end
