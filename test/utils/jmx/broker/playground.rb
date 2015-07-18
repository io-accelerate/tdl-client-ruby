
require 'jmx4r'

require 'java'
import org.jruby.RubyString

JMX::MBean.establish_connection :host => 'localhost', :port => 20011

broker = JMX::MBean.find_by_name 'org.apache.activemq:type=Broker,brokerName=TEST.BROKER'
# puts broker.attributes
puts broker.broker_version

queue = JMX::MBean.find_by_name 'org.apache.activemq:type=Broker,brokerName=TEST.BROKER,destinationType=Queue,destinationName=test.resp'

# BUGFIX. We need to add the operation to the map, before we can call it
queue.operations['send_text_message'] = ['sendTextMessage', ['java.lang.String']]
# puts queue.operations
queue.send_text_message 'from playground'

# bytes = 'a string'.to_java_bytes
# p bytes
# p RubyString.bytes_to_string(bytes)

queue.operations["browse"] = ["browse", []]
puts queue.browse.take(1).map  { |compositeData|
       if compositeData.containsKey("Text")
         compositeData.containsKey("BodyPreview")
       else
         compositeData.get("BodyPreview").to_a.pack('c*')
       end
}