module TDL
  class FatalErrorResponse
    attr_reader :message
    
    def initialize(message)
      @message = message
    end
  end
end
