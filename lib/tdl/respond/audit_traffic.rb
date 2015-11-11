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

      @logger.info "id = #{request.id}, req = #{request.to_h[:method]}(#{request.params.join(", ")}), resp = #{response.result}"
      # DEBT method method taken on ostruct

      response
    end
  end
end
