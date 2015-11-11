require 'tdl/abstractions/request'
require 'tdl/abstractions/response'

module TDL
  class AuditTraffic
    def initialize(wrapped_strategy)
      @wrapped_strategy = wrapped_strategy
      @logger = Logging.logger[self]
    end

    def respond_to(request)
      response = @wrapped_strategy.respond_to(request)

      @logger.info "id = #{request.id}, req = #{request.params}"
      # DEBT does not log request response

      response
    end
  end
end
