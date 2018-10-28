require 'tdl/util'

module TDL
  class ValidResponse
    attr_reader :id, :result

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
      "resp = #{TDL::Util.compress_data(@result)}"
    end
  end
end
