require 'tdl/abstractions/request'
require 'tdl/abstractions/response'

module TDL
  class JSONRPCSerializationProvider
    def initialize
      @logger = Logging.logger[self]
    end

    def deserialize(message_text)
      json = JSON.parse(message_text).first
      json = JSON.parse(json)

      OpenStruct.new(json)
      # DEBT means there is no Request object needed
    end

    def serialize(response)
      if response
        hash = response.to_h
        JSON.unparse(hash)
      end
    end
  end
end
