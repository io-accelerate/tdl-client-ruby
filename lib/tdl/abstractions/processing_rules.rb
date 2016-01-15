require 'tdl/abstractions/processing_rule'

module TDL
  class ProcessingRules

    def initialize
      @rules = Hash.new
    end

    def add(method_name, user_implementation, client_action)
      @rules[method_name] = ProcessingRule.new(user_implementation, client_action)
    end


    def get_rule_for(request)
      if @rules.has_key?(request.method)
        @rules[request.method]
      else
        raise NameError.new("Method #{request.method} did not match any processing rule.")
      end
    end

  end
end
