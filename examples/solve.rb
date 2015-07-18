require 'tdl'

client = TDL::Client.new('stomp://localhost:21613', 'test')

client.go_live_with { |params| p params }