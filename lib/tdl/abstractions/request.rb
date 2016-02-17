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
      "id = #{@id}, req = #{@method}(#{@params.map{|p| "\"#{p}\""}.join(', ')})"
    end
  end
end
