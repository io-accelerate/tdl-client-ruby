module TDL
  class FatalErrorResponse

    def initialize(message)
      @message = message
    end

    def audit_text
      "error = #{@message}, (NOT PUBLISHED)"
    end
  end
end
