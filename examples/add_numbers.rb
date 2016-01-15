require 'tdl'
require 'logging'

Logging.logger.root.appenders = Logging.appenders.stdout
Logging.logger.root.level = :info


def run_client
  client = TDL::Client.new('localhost', 61613, 'julian')
  include TDL::ClientActions
  rules = TDL::ProcessingRules.new
  rules.on('display_description').call(method(:display)).then(publish)
  rules.on('display_required_methods').call(method(:display)).then(publish)
  rules.on('increment').call(method(:increment)).then(publish_and_stop)

  # puts processing_rules.to_yaml

  client.go_live_with(rules)
end

def display(str)
  puts str
  'OK'
end

def increment(x)
  x + 1
end


run_client