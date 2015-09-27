$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter '/test/'
end

require 'tdl'
require 'json'
require 'net/http'
require 'utils/jmx/broker/jolokia_session'
require 'utils/jmx/broker/remote_jmx_broker'
require 'utils/jmx/broker/remote_jmx_queue'
require 'utils/jmx/broker/testing/active_mq_broker_rule'

require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Reporters.use!

require 'logging'
Logging.logger.root.appenders = Logging.appenders.stdout
Logging.logger.root.level = :debug