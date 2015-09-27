
require 'json'
require './jolokia_session'


jolokia_session = JolokiaSession.connect('localhost',28161)

# Add queue
operation = {
    type: 'exec',
    mbean: 'org.apache.activemq:type=Broker,brokerName=TEST.BROKER',
    operation: 'addQueue',
    arguments: ['test.req']
}
jolokia_session.request(operation)

# Send message
operation = {
    type: 'exec',
    mbean: 'org.apache.activemq:type=Broker,brokerName=TEST.BROKER,destinationType=Queue,destinationName=test.req',
    operation: 'sendTextMessage(java.lang.String)',
    arguments: ['test message']
}
jolokia_session.request(operation)

# Read queue size
attribute = {
    type: 'read',
    mbean: 'org.apache.activemq:type=Broker,brokerName=TEST.BROKER,destinationType=Queue,destinationName=test.req',
    attribute: 'QueueSize',
}
result = jolokia_session.request(attribute)
puts "Value = #{result}"

# Browse queues
operation = {
    type: 'exec',
    mbean: 'org.apache.activemq:type=Broker,brokerName=TEST.BROKER,destinationType=Queue,destinationName=test.req',
    operation: 'browse()',
}
result = jolokia_session.request(operation)
puts result.inspect
puts result.map  { |composite_data|


  composite_data['Text']
}

# Purge
operation = {
    type: 'exec',
    mbean: 'org.apache.activemq:type=Broker,brokerName=TEST.BROKER,destinationType=Queue,destinationName=test.req',
    operation: 'purge()',
}
jolokia_session.request(operation)