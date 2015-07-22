require 'tdl/abstractions/request'
require 'tdl/abstractions/response'

module TDL
  class ValidateResponse
    def initialize(wrapped_strategy)
      @wrapped_strategy = wrapped_strategy
      @logger = Logging.logger[self]
    end

    def respond_to(request)
      response = @wrapped_strategy.respond_to(request)
      (response.result == nil) ? nil : response
    end
  end
end