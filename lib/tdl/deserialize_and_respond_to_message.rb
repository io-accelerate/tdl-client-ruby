require 'tdl/serialization/json_rpc_serialization_provider'
require 'tdl/respond/validate_response'
require 'tdl/respond/audit_traffic'
require 'tdl/respond/obtain_response'

module TDL
  class DeserializeAndRespondToMessage
    def initialize(user_implementation)
      @serialization_provider = JSONRPCSerializationProvider.new
      @response_strategy = ValidateResponse.new(AuditTraffic.new(ObtainResponse.new(user_implementation)))
      @logger = Logging.logger[self]
    end

    def self.using(user_implementation)
      DeserializeAndRespondToMessage.new(user_implementation)
    end

    def respond_to(message_text)
      # puts message_text
      request = @serialization_provider.deserialize(message_text)
      # puts request
      response = @response_strategy.respond_to(request)
      # puts response
      @serialization_provider.serialize(response)
    end
  end
end
