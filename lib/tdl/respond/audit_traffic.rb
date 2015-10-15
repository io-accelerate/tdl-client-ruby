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

      #DEBT parameters contain strange charachters from CSV parsing.
      pretty_print_params = "[" + request.params.map{|e| e.gsub(/([^\w\d]+)/, "")}.join(", ") + "]"

      request_id = request.id.gsub(/([^\w\d]+)/, "")
      @logger.info "id = #{request_id}, req = #{pretty_print_params}, resp = #{response.result}"

      response
    end
  end
end
