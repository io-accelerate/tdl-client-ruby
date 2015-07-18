
require 'jmx4r'

JMX::MBean.establish_connection :host => "localhost", :port => 20011

broker = JMX::MBean.find_by_name "org.apache.activemq:type=Broker,brokerName=TEST.BROKER"
# puts broker.attributes
puts broker.broker_version

queue = JMX::MBean.find_by_name "org.apache.activemq:type=Broker,brokerName=TEST.BROKER,destinationType=Queue,destinationName=test.req"
puts queue.operations
# "send_text_message"=>["sendTextMessage", ["java.util.Map", "java.lang.String", "java.lang.String", "java.lang.String"]],
# queue.send_text_message "hehe"