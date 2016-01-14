require 'tdl/serialization/json_rpc_serialization_provider'
require 'tdl/respond/validate_response'
require 'tdl/respond/audit_traffic'
require 'tdl/respond/obtain_response'

module TDL
  class DeserializeAndRespondToMessage
    def initialize(processing_rules)
      @serialization_provider = JSONRPCSerializationProvider.new
      @response_strategy = ValidateResponse.new(AuditTraffic.new(ObtainResponse.new(processing_rules)))
      @logger = Logging.logger[self]
    end

    def self.using(processing_rules)
      DeserializeAndRespondToMessage.new(processing_rules)
    end

    def respond_to(message_text)
      request = @serialization_provider.deserialize(message_text)
      response = @response_strategy.respond_to(request)
      @serialization_provider.serialize(response)
    end
  end
end
