require 'tdl/abstractions/request'
require 'tdl/abstractions/response'

module TDL
  class CsvSerializationProvider
    def initialize
      @logger = Logging.logger[self]
    end

    def deserialize(message_text)
      # IO.inspect message_text
      # IO.inspect message_text.class

      items = message_text.split(', ', 2)
      @logger.debug("Received items: #{items}")

      request_id = items[0]
      serialized_params = items[1]
      params = serialized_params.split(', ')

      Request.new(request_id, params)
    end

    def serialize(response)
      (response == nil) ? nil : "#{response.id}, #{response.result}"
    end
  end
end
