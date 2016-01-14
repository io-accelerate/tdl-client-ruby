require 'tdl/abstractions/request'
require 'tdl/abstractions/response'

module TDL
  class ObtainResponse
    def initialize(processing_rules)
      @processing_rules = processing_rules
      @logger = Logging.logger[self]
    end

    def respond_to(request)
      begin
        # DEBT method is a default method on objects
        # o = OpenStruct.new({method: 5})
        # o.method !! Error

        # DEBT object is treated and a collection of anonymous methods and not a normal object this is not ideomatic ruby


        processing_rule = @processing_rules.get_rule_for(request)
        user_implementation = processing_rule.user_implementation
        result = user_implementation.call(*request.params)
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
