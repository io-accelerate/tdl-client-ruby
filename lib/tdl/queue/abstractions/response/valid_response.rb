require 'tdl/util'

module TDL
  class ValidResponse
    attr_reader :id, :result, :client_action

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
      "resp = #{TDL::Util.compress_data(@result)}"
    end
  end
end
