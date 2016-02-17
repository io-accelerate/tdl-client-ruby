require 'tdl/abstractions/processing_rule'
require 'tdl/abstractions/response/fatal_error_response'
require 'tdl/abstractions/response/valid_response'
require 'tdl/actions/client_actions'

module TDL
  class ProcessingRules

    def initialize
      @rules = Hash.new
      @logger = Logging.logger[self]
    end

    # ~~~~ Builders

    def add(method_name, user_implementation, client_action)
      @rules[method_name] = ProcessingRule.new(user_implementation, client_action)
    end

    def on(method_name)
      ProcessingRuleBuilder.new(self, method_name)
    end

    class ProcessingRuleBuilder

      def initialize(instance, method_name)
        @instance = instance
        @method_name = method_name
      end

      def call(user_implementation)
        @user_implementation = user_implementation
        self
      end

      def then(client_action)
        @instance.add(@method_name, @user_implementation, client_action)
      end
    end


    # ~~~~ Accessors

    def get_response_for(request)
      if @rules.has_key?(request.method)
        processing_rule = @rules[request.method]
      else
        message = "\"method '#{request.method}' did not match any processing rule\""
        @logger.warn(message)
        return FatalErrorResponse.new(message)
      end

      begin
        user_implementation = processing_rule.user_implementation
        result = user_implementation.call(*request.params)

        return ValidResponse.new(request.id, result, processing_rule.client_action)
      rescue Exception => e
        message = 'user implementation raised exception'
        @logger.warn("#{message}, #{e.message}")
        @logger.warn e.backtrace.join("\n")
        return FatalErrorResponse.new(message)
      end
    end

  end
end
