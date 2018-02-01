require 'tdl/audit/console_audit_stream'

module TDL

    class ImplementationRunnerConfig
        
        def initialize
            @port = 61616
            @time_to_wait_for_requests = 500
            @audit_stream = ConsoleAuditStream.new
        end

        def set_hostname(hostname)
            @hostname = hostname
            self
        end

        def set_port(port)
            @port = port
            self
        end

        def set_unique_id(unique_id)
            @unique_id = unique_id
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

        def get_unique_id
            @unique_id
        end

        def get_time_to_wait_for_requests
            @time_to_wait_for_requests
        end

        def get_audit_stream
            @audit_stream
        end
    end
    
end
