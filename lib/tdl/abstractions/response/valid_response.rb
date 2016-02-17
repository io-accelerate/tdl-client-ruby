module TDL
  class ValidResponse
    attr_reader :result, :id, :client_action

    def initialize(id, result, client_action)
      @id = id
      @result = result
      @client_action = client_action
    end

    def to_h
      {
        :result => @result,
        :error => nil,
        :id => @id,
      }
    end

    def audit_text
      # DEBT duplicated in request
      if @result.respond_to?(:split)
        first, *last = @result.split("\n")
        if last
          "resp = \"#{first} .. ( #{last.size} more line#{ 's' if last.size != 1 } )\""
        else
          "\"#{first}\""
        end
      else
        "resp = #{@result}"
      end
    end
  end
end
