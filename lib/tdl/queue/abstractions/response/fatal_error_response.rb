module TDL
  class FatalErrorResponse

    def initialize(message)
      @message = message + ", (NOT PUBLISHED)"
    end

    def audit_text
      "error = #{@message}"
    end
  end
end
