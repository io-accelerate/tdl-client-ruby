module TDL
  class FatalErrorResponse

    def initialize(message)
      @message = message
    end

    def audit_text
      "error = #{message}"
    end
  end
end
