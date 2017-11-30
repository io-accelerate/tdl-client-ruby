class ThreadTimer
  def initialize(timeout_millis, callback)
    @timeout_millis=timeout_millis
    @continue = true
    @callback = callback
    @timer_thread = nil
  end

  def start_timer
    @continue = true
    @timer_thread = Thread.new { start_timeout }
  end

  def stop_timer
    @continue = false
    @timer_thread.terminate unless @timer_thread.nil?
    @timer_thread = nil
  end

  private

  def start_timeout
    total_millis = 0
    interval_millis = 10
    while @continue && total_millis < @timeout_millis
      sleep interval_millis / 1000.00
      total_millis += interval_millis
    end

    if total_millis >= @timeout_millis
      @callback.call
    end
  end
end