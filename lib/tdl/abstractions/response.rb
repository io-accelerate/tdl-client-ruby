module TDL
  class Response
    attr_reader :result, :id

    def initialize(id, result)
      @id = id
      @result = result
    end

    def to_h
      {
        :result => @result,
        :error => nil,
        :id => @id,
      }
    end

    def audit_text
      "resp = #{@result}"
    end
  end
end
