module TDL
  class Response
    attr_reader :result, :id

    def initialize(id, result)
      @id = id
      @result = result
    end
  end
end