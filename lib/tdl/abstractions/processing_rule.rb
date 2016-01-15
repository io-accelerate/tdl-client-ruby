require 'tdl/actions/publish_action'
require 'tdl/actions/stop_action'
require 'tdl/actions/publish_and_stop_action'


module TDL
  class ProcessingRule
    attr_reader :user_implementation, :s_client_action

    def initialize(user_implementation, client_action)
      @user_implementation = user_implementation
      @s_client_action = client_action
    end

    def client_action

      case @s_client_action
        when 'publish'
          PublishAction.new
        when 'stop'
          StopAction.new
        when 'publish and stop'
          PublishAndStopAction.new
        else
          raise 'Could not match action'
      end
    end
  end
end
