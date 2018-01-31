class TestAuditStream
  def initialize
    @total = ''
  end

  def write_line(s)
    @total += "#{s}\n"
  end

  def get_log
    total = @total
    puts total
    @total = ''
    total
  end
end
