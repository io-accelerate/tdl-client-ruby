$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'tdl'
require 'jmx4r'
require 'utils/jmx/broker/remote_jmx_broker'
require 'utils/jmx/broker/remote_jmx_queue'
require 'utils/jmx/broker/active_mq_broker_rule'

require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Reporters.use!
