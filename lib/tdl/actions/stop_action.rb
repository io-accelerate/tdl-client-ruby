module TDL
  class StopAction

    def audit_text
      '(NOT PUBLISHED)'
    end

    def after_response(remote_broker, request, response)
      # do nothing
    end

    def prepare_for_next_request(remote_broker)
      remote_broker.close
    end

  end
end
