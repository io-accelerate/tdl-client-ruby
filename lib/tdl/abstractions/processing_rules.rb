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
      method_name = request.to_h[:method]

      if @rules.has_key?(method_name)
        @rules[method_name]
      else
        raise NameError.new("Method #{method_name} did not match any processing rule.")
      end
    end

  end
end
