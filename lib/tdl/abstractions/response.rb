module TDL
  class Response
    attr_reader :result, :id

    def initialize(request, result)
      @id = request.id
      @result = result
    end

    def to_h
      {
        :result => @result,
        :error => nil,
        :id => @id,
      }
    end
  end
end
