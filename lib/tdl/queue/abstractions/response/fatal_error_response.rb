require 'tdl/queue/actions/stop_action'

module TDL
  class FatalErrorResponse

    def initialize(message)
      @message = message
    end

    def client_action
      StopAction.new
    end

    def audit_text
      "error = #{@message}"
    end
  end
end
