
class RemoteJmxQueue

  def initialize(jolokia_session, broker_name, queue_name)
    @jolokia_session = jolokia_session
    @queue_bean = "org.apache.activemq:type=Broker,brokerName=#{broker_name},destinationType=Queue,destinationName=#{queue_name}"
  end

  def send_text_message(request)
    operation = {
        type: 'exec',
        mbean: @queue_bean,
        operation: 'sendTextMessage(java.lang.String)',
        arguments: [ request ]
    }
    @jolokia_session.request(operation)
  end

  def get_size
    attribute = {
        type: 'read',
        mbean: @queue_bean,
        attribute: 'QueueSize',
    }
    @jolokia_session.request(attribute)
  end

  def get_message_contents
    operation = {
        type: 'exec',
        mbean: @queue_bean,
        operation: 'browse()',
    }
    result = @jolokia_session.request(operation)
    result.map  { |composite_data|
      if composite_data.has_key?('Text')
        composite_data['Text']
      else
        composite_data['BodyPreview'].to_a.pack("c*")
      end
    }
  end

  def purge
    operation = {
        type: 'exec',
        mbean: @queue_bean,
        operation: 'purge()',
    }
    @jolokia_session.request(operation)
  end

end
