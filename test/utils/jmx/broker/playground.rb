
require 'jmx4r'

JMX::MBean.establish_connection :host => "localhost", :port => 20011

broker = JMX::MBean.find_by_name "org.apache.activemq:type=Broker,brokerName=TEST.BROKER"
# puts broker.attributes
puts broker.broker_version

queue = JMX::MBean.find_by_name "org.apache.activemq:type=Broker,brokerName=TEST.BROKER,destinationType=Queue,destinationName=test.req"

# BUGFIX. We need to add the operation to the map, before we can call it
queue.operations["send_text_message"] = ["sendTextMessage", ["java.lang.String"]]
# puts queue.operations
queue.send_text_message "from playground"

queue.operations["browse"] = ["browse", []]
puts queue.browse.map  { |compositeData| compositeData.get("Text") }