class AuditStream
  def initialize
    @logger = Logging.logger[self]
    start_line
  end

  def start_line
    @str = ''
  end

  def log_request(request)
    params_as_string = TDL::PresentationUtil.to_displayable_request(request.params)
    text = "id = #{request.id}, req = #{request.method}(#{params_as_string})"

    if not text.empty? and @str.length > 0
      @str << ', '
    end
    @str << text
  end

  def log_response(response)
    if response.instance_variable_defined?(:@result)
      representation = TDL::PresentationUtil.to_displayable_response(response.result)
      text = "resp = #{representation}"
    else
      text = "error = #{response.message}" + ", (NOT PUBLISHED)"
    end

    if not text.empty? and @str.length > 0
      @str << ', '
    end
    @str << text
  end

  def end_line
    @logger.info @str
  end
end