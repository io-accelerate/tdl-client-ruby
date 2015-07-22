require 'tdl/abstractions/request'
require 'tdl/abstractions/response'

module TDL
  class ObtainResponse
    def initialize(user_implementation)
      @user_implementation = user_implementation
      @logger = Logging.logger[self]
    end

    def respond_to(request)
      begin
        result = @user_implementation.call(request.params)
      rescue Exception => e
        @logger.info "The user implementation has thrown exception. #{e.message}"
        result = nil
      end

      if result.nil?
        @logger.info 'User implementation has returned "nil"'
      end

      Response.new(request.id, result)
    end
  end
end