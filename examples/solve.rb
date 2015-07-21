require 'tdl'
require 'logging'

Logging.logger.root.appenders = Logging.appenders.stdout

client = TDL::Client.new('localhost', 21613, 'test')

client.go_live_with { |params|
  x = params[0].to_i
  y = params[1].to_i
  x + y
}