require 'tdl/abstractions/processing_rule'
require 'tdl/actions/client_actions'

module TDL
  class ProcessingRules

    def initialize
      @rules = Hash.new
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

    def get_rule_for(request)
      if @rules.has_key?(request.method)
        @rules[request.method]
      else
        raise NameError.new("Method #{request.method} did not match any processing rule.")
      end
    end

  end
end
