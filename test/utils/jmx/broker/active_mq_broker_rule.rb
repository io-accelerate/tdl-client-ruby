

class ActiveMQBrokerRule

  def initialize(hostname, port, broker_name)
    @hostname = hostname
    @port = port
    @broker_name = broker_name
  end

  def connect
    @remote_jmx_broker = RemoteJmxBroker.connect(@hostname, @port, @broker_name)
  end

  #~~~~ Facade to broker

  def add_queue(queue_name)
    @remote_jmx_broker.add_queue(queue_name)
  end

end