module TDL
  Request = Struct.new(:original_message, :id, :method, :params) do
    def self.deserialize(original_message, request_data)
      new(
        original_message,
        request_data.fetch('id'),
        request_data.fetch('method'),
        request_data.fetch('params')
      )
    end
  end
end