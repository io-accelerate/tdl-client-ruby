require 'tdl/queue/actions/publish_action'
require 'tdl/queue/actions/stop_action'
require 'tdl/queue/actions/publish_and_stop_action'

module TDL
  module ClientActions

    def publish
      PublishAction.new
    end

    def stop
      StopAction.new
    end

    def publish_and_stop
      PublishAndStopAction.new
    end
  end
end
