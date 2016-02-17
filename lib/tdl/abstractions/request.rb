module TDL
  class Request
    attr_reader :original_message, :id, :method, :params

    def initialize(original_message, request_data)
      @original_message = original_message
      @id = request_data['id']
      @method = request_data['method']
      @params = request_data['params']
    end

    def audit_text
      # DEBT Quotes parameters that are not strings.
      "id = #{@id}, req = #{@method}(#{@params.map{ |param|
        if param.respond_to?(:split)
          first, *last = param.split("\n")
          if last
            "\"#{first} .. ( #{last.size} more line#{ 's' if last.size != 1 } )\""
          else
            "\"#{first}\""
          end
        else
          param
        end
      }.join(', ')})"
    end
  end
end
