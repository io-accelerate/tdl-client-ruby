
class RemoteJmxBroker

  def initialize(jolokia_session, broker_name)
    @jolokia_session = jolokia_session
    @broker_name = broker_name
  end

  def self.connect(host, port, broker_name)
    begin
      jolokia_session = JolokiaSession.connect(host, port)
    rescue Exception => e
      puts "Broker is busted: #{e}"
    end

    RemoteJmxBroker.new(jolokia_session, broker_name)
  end

  #~~~~ Queue management

  def add_queue(queue_name)
    operation = {
        type: 'exec',
        mbean: "org.apache.activemq:type=Broker,brokerName=#{@broker_name}",
        operation: 'addQueue',
        arguments: [queue_name]
    }
    @jolokia_session.request(operation)
    RemoteJmxQueue.new(@jolokia_session, @broker_name, queue_name)
  end

end