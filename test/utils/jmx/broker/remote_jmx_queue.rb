
class RemoteJmxQueue

  def initialize(jmx_session, broker_name, queue_name)
    @jmx_session = jmx_session
    @broker_name = broker_name
    @queue_name = queue_name
  end

  def send_text_message(request)
    queue = @jmx_session.find_by_name("org.apache.activemq:type=Broker,brokerName=#{@broker_name},destinationType=Queue,destinationName=#{@queue_name}")

  end

  def get_size()
    queue = @jmx_session.find_by_name("org.apache.activemq:type=Broker,brokerName=#{@broker_name},destinationType=Queue,destinationName=#{@queue_name}")
    queue.queue_size
  end

  def get_message_contents()
    'x'
  end

  def purge
    # code here
  end

end