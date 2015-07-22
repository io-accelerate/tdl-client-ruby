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

      pretty_print_params = request.params.to_s.gsub('"', '')
      @logger.info "id = #{request.id}, req = #{pretty_print_params}, resp = #{response.result}"

      response
    end
  end
end