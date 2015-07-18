
class RemoteJmxBroker

  def initialize(jmx_session, broker_name)
    @jmx_session = jmx_session
    @broker_name = broker_name
  end

  def self.connect(host, port, broker_name)
    begin
      JMX::MBean.establish_connection(:host => host, :port => port)
    rescue Exception => e
      puts "Broker is busted: #{e}"
    end

    RemoteJmxBroker.new(JMX::MBean, broker_name)
  end

  #~~~~ Queue management



  def add_queue(queue_name)
    broker  = @jmx_session.find_by_name("org.apache.activemq:type=Broker,brokerName=#{@broker_name}")
    broker.add_queue(queue_name)
    RemoteJmxQueue.new(@jmx_session, @broker_name, queue_name)
  end

end