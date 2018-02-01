require 'json'
require 'tdl/queue/abstractions/request'
require 'tdl/queue/serialization/deserialization_exception'

module TDL
  class JSONRPCSerializationProvider
    def initialize
      @logger = Logging.logger[self]
    end

    def deserialize(msg)
      begin
        request_data = JSON.parse(msg.body.gsub("\n", '\n'))
        Request.new(msg, request_data)
      rescue Exception => e
        raise e if ENV['TDL_ENV'] == 'test'
        raise DeserializationException,'Invalid message format', e.backtrace
      end
    end

    def serialize(response)
      if response
        hash = response.to_h
        JSON.unparse(hash)
      end
    end
  end
end
