require 'json'
require 'tdl/abstractions/request'
require 'tdl/abstractions/response'

module TDL
  class JSONRPCSerializationProvider
    def initialize
      @logger = Logging.logger[self]
    end

    def deserialize(msg)
      request_data = JSON.parse(msg.body)
      Request.new(msg, request_data)
    end

    def serialize(response)
      if response
        hash = response.to_h
        JSON.unparse(hash)
      end
    end
  end
end
