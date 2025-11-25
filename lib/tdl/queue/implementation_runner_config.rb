require 'tdl/audit/console_audit_stream'

module TDL

    class ImplementationRunnerConfig
        
        def initialize
            @port = 61613
            @time_to_wait_for_requests = 1500
            @audit_stream = ConsoleAuditStream.new
            @request_queue_name = ''
            @response_queue_name = ''
        end

        def set_hostname(hostname)
            @hostname = hostname
            self
        end

        def set_port(port)
            @port = port
            self
        end

        def set_request_queue_name(queue_name)
            @request_queue_name = queue_name
            self
        end

        def set_response_queue_name(queue_name)
            @response_queue_name = queue_name
            self
        end

        def set_time_to_wait_for_requests(time_to_wait_for_requests)
            @time_to_wait_for_requests = time_to_wait_for_requests
            self
        end

        def set_audit_stream(audit_stream)
            @set_audit_stream = audit_stream
            self
        end

        def get_hostname
            @hostname
        end

        def get_port
            @port
        end

        def get_request_queue_name
            @request_queue_name
        end

        def get_response_queue_name
            @response_queue_name
        end

        def get_time_to_wait_for_requests
            @time_to_wait_for_requests
        end

        def get_audit_stream
            @audit_stream
        end
    end
    
end
