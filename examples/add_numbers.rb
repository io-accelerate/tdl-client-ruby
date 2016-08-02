require 'tdl'
require 'logging'

Logging.logger.root.appenders = Logging.appenders.stdout
Logging.logger.root.level = :info


def run_client
  client = TDL::Client.new( hostname: 'localhost', port: 61613, unique_id: 'julian@example.com')
  include TDL::ClientActions
  rules = TDL::ProcessingRules.new
  rules.on('display_description').call(method(:display)).then(publish)
  rules.on('sum').call(method(:sum)).then(publish)
  rules.on('end_round').call(lambda { 'OK' }).then(publish_and_stop)

  # puts processing_rules.to_yaml

  client.go_live_with(rules)
end

def display(round, description)
  puts "#{round} = #{description}"
  'OK'
end

def sum(x, y)
  x + y
end


run_client