
class RemoteJmxQueue

  def initialize(jmx_session, broker_name, queue_name)
    @queue = jmx_session.find_by_name("org.apache.activemq:type=Broker,brokerName=#{broker_name}"\
          ",destinationType=Queue,destinationName=#{queue_name}")
  end

  def send_text_message(request)
    @queue.operations['send_text_message'] = ['sendTextMessage', ['java.lang.String']]
    @queue.send_text_message(request)
  end

  def get_size()
    @queue.queue_size
  end

  def get_message_contents()
    @queue.operations["browse"] = ["browse", []]
    @queue.browse.map  { |compositeData| compositeData.get("Text") }
  end

  def purge
    @queue.purge
  end

end