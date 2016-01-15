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
      "id = #{@id}, req = #{@method}(#{@params.join(', ')})"
    end
  end
end
