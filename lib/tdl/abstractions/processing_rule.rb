require 'tdl/actions/publish_action'
require 'tdl/actions/stop_action'
require 'tdl/actions/publish_and_stop_action'


module TDL
  class ProcessingRule
    attr_reader :user_implementation, :client_action

    def initialize(user_implementation, client_action)
      @user_implementation = user_implementation
      @client_action = client_action
    end
  end
end
