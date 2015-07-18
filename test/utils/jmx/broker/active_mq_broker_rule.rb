require 'jmx'

class ActiveMQBrokerRule

  def initialize(hostname, port, broker_name)
    @hostname = hostname
    @port = port
    @broker_name = broker_name
  end

  def connect

  end

  #~~~~ Facade to broker

  def add_queue(queue_name)
    RemoteJmxQueue.new
  end

end