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
        # DEBT method is a default method on objects
        # o = OpenStruct.new({method: 5})
        # o.method !! Error

        # DEBT object is treated and a collection of anonymous methods and not a normal object this is not ideomatic ruby

        result = @user_implementation.send(request.to_h[:method]).(*request.params)
      rescue Exception => e
        @logger.info "The user implementation has thrown exception. #{e.message}"
        result = nil
        raise $! if ENV["RUBY_ENV"] == "test"
      end

      if result.nil?
        @logger.info 'User implementation has returned "nil"'
      end

      Response.new(request, result)
    end
  end
end
