require 'tdl/util'

module TDL
  class Request
    attr_reader :original_message, :id, :method, :params

    def initialize(original_message, request_data)
      @original_message = original_message
      @id = request_data.fetch('id')
      @method = request_data.fetch('method')
      @params = request_data.fetch('params')
    end
  end
end
